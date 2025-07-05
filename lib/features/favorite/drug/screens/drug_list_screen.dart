import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/drug_list_item.dart';
import 'drug_detail_screen.dart';
// لا حاجة لاستيراد AppLocalizations

class DrugListScreen extends StatefulWidget {
  const DrugListScreen({super.key});

  @override
  State<DrugListScreen> createState() => _DrugListScreenState();
}

class _DrugListScreenState extends State<DrugListScreen> {
  final ApiService _apiService = ApiService();
  List<DrugListItem> _drugs = [];
  bool _isLoading = true;
  String? _error;

  final ScrollController _scrollController = ScrollController();
  int _currentPageToFetch = 0;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialDrugs();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchInitialDrugs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _drugs.clear();
      _currentPageToFetch = 0;
      _hasMoreData = true;
    });
    await _loadMoreDrugs();
    if (!mounted) return;
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreDrugs() async {
    if (_isLoadingMore || !_hasMoreData || !mounted) return;
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        if (!_isLoading) _error = null;
      });
    }
    try {
      List<DrugListItem> newDrugs = await _apiService.fetchDrugList(skip: _currentPageToFetch * 20, limit: 20);
      if (mounted) {
        setState(() {
          if (newDrugs.isEmpty) {
            _hasMoreData = false;
          } else {
            _drugs.addAll(newDrugs);
            _currentPageToFetch++;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
      debugPrint("Error fetching drugs in _loadMoreDrugs: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          if (_isLoading) _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMoreData &&
        !_isLoading
    ) {
      _loadMoreDrugs();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // لا حاجة لـ l10n هنا

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الأدوية'), // نص عربي ثابت
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (_isLoading || _isLoadingMore) ? null : _fetchInitialDrugs,
            tooltip: 'تحديث القائمة', // نص عربي ثابت
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _drugs.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('جار التحميل...', style: Theme.of(context).textTheme.titleMedium) // نص عربي ثابت
        ],
      ));
    } else if (_error != null && _drugs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 60),
              const SizedBox(height: 20),
              Text('خطأ في تحميل البيانات: $_error', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error)), // يمكن ترك _error كما هو
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchInitialDrugs,
                label: const Text('إعادة المحاولة'), // نص عربي ثابت
              )
            ],
          ),
        ),
      );
    } else if (_drugs.isEmpty && !_hasMoreData && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medication_liquid_outlined, color: Colors.grey[400], size: 60),
              const SizedBox(height: 20),
              Text('لا توجد أدوية لعرضها حاليًا.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium), // نص عربي ثابت
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchInitialDrugs,
                label: const Text('حاول التحديث'), // نص عربي ثابت
              )
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_error != null && _drugs.isNotEmpty && !_isLoadingMore)
          Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(child: Text("حدث خطأ أثناء تحميل المزيد: $_error", style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer))), // يمكن ترك _error
                IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onErrorContainer),
                    onPressed: () => setState(() => _error = null)
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: _drugs.length,
            itemBuilder: (context, index) {
              final drug = _drugs[index];
              String title = drug.brandName;
              String? subtitle;
              if (drug.genericName != "N/A" && drug.genericName.isNotEmpty && drug.genericName.toLowerCase() != drug.brandName.toLowerCase()) {
                subtitle = drug.genericName;
              }

              bool canNavigate = drug.splSetId.isNotEmpty || drug.productNdc.isNotEmpty;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Icon(
                    Icons.medication_outlined,
                    color: canNavigate ? Theme.of(context).colorScheme.primary : Colors.grey[400],
                    size: 32,
                  ),
                  title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // سيعرض الاسم الإنجليزي
                  subtitle: subtitle != null ? Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])) : null, // سيعرض الاسم الإنجليزي
                  trailing: canNavigate ? Icon(Icons.arrow_forward_ios, size: 18, color: Theme.of(context).colorScheme.primary) : null,
                  onTap: canNavigate ? () {
                    if (drug.splSetId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrugDetailScreen(
                            identifier: drug.splSetId,
                            drugName: title,
                            isNdc: false,
                          ),
                        ),
                      );
                    } else if (drug.productNdc.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrugDetailScreen(
                            identifier: drug.productNdc,
                            drugName: title,
                            isNdc: true,
                          ),
                        ),
                      );
                    }
                  } : (){
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar( // نص عربي ثابت
                        content: Text('التفاصيل غير متوفرة لهذا الدواء.'),
                        backgroundColor: Colors.grey,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (_isLoadingMore)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text('جار التحميل...', style: Theme.of(context).textTheme.bodySmall) // نص عربي ثابت
              ],
            )),
          ),
        if (!_hasMoreData && _drugs.isNotEmpty && !_isLoadingMore && _error == null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("لقد وصلت إلى نهاية القائمة.", style: Theme.of(context).textTheme.bodySmall)), // نص عربي ثابت
          ),
      ],
    );
  }
}