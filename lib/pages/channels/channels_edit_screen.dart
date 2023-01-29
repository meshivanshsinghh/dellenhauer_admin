import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChannelEditScreen extends StatefulWidget {
  final ChannelModel channelModel;
  const ChannelEditScreen({super.key, required this.channelModel});

  @override
  State<ChannelEditScreen> createState() => _ChannelEditScreenState();
}

class _ChannelEditScreenState extends State<ChannelEditScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Center(
          child: AppBar(
            elevation: 1,
            title: const Text('Edit Channel'),
            // title: RichText(
            //   text: TextSpan(children: [
            //     const TextSpan(
            //         text: 'Edit Channel: ',
            //         style: TextStyle(
            //             fontWeight: FontWeight.w800, color: Colors.black)),
            //     TextSpan(
            //         text: widget.channelModel.channelName,
            //         style: const TextStyle(
            //             color: Colors.black87, fontWeight: FontWeight.w400)),
            //   ]),
            // ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: EdgeInsets.only(
          left: w * 0.05,
          right: w * 0.20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 10,
              offset: const Offset(3, 3),
            )
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('data')],
          ),
        ),
      ),
    );
  }
}
