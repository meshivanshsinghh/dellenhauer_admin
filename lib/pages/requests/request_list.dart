import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/pages/requests/requests_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestListScreen extends StatefulWidget {
  final ChannelModel channelModel;
  const RequestListScreen({super.key, required this.channelModel});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  late RequestsProvider requestsProvider;
  ScrollController? scrollController;
  late String orderBy;
  late bool descending;
  String? sortByText;

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'createdAt';
    descending = true;
    Future.delayed(Duration.zero, () {
      scrollController = ScrollController()..addListener(_scrollListener);
      requestsProvider = Provider.of<RequestsProvider>(context, listen: false);
      requestsProvider.attachContext(context);
      requestsProvider.setChannelDataLoading(isLoading: true);
      requestsProvider.getChannelRequestList(
        orderBy: orderBy,
        descending: descending,
        channelId: widget.channelModel.groupId,
      );
    });
  }

  void _scrollListener() async {
    requestsProvider = Provider.of<RequestsProvider>(context, listen: true);
    if (!requestsProvider.isLoadingChannelList) {
      if (scrollController!.position.pixels ==
          scrollController!.position.maxScrollExtent) {
        requestsProvider.setChannelDataLoading(isLoading: true);
        requestsProvider.getChannelRequestList(
          orderBy: orderBy,
          descending: descending,
          channelId: widget.channelModel.groupId,
        );
      }
    }
  }

  void refreshData() {
    requestsProvider = Provider.of<RequestsProvider>(context, listen: false);
    requestsProvider.setLastVisibleChannelRequestList(lastVisible: null);
    requestsProvider.setChannelDataLoading(isLoading: true);
    requestsProvider.requestData.clear();
    requestsProvider.getChannelRequestList(
      orderBy: orderBy,
      descending: descending,
      channelId: widget.channelModel.groupId,
    );
    requestsProvider.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
