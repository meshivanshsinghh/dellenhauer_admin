import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/providers/channels_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../utils/widgets/empty.dart';

class ChannelListSelectionScreen extends StatefulWidget {
  const ChannelListSelectionScreen({super.key});

  @override
  State<ChannelListSelectionScreen> createState() =>
      _ChannelListSelectionScreenState();
}

class _ChannelListSelectionScreenState
    extends State<ChannelListSelectionScreen> {
  late ChannelProvider channelProvider;

  @override
  Widget build(BuildContext context) {
    channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    return FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 0.8,
        child: Scaffold(
            body: Column(
          children: [
            FutureBuilder<List<ChannelModel>>(
                future: channelProvider.getChannelList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return channelBuilder(snapshot.data![index]);
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    emptyPage(FontAwesomeIcons.circleXmark, 'Error');
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return Center(
                      child: emptyPage(
                        FontAwesomeIcons.trophy,
                        'No awards found!',
                      ),
                    );
                  }
                  return const SizedBox(
                    height: 500,
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  );
                }),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
              ),
              child: const Text('Close'),
            ),
            const SizedBox(height: 20),
          ],
        )));
  }

  Widget channelBuilder(ChannelModel channelModel) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: channelModel.channelPhoto!,
          placeholder: (context, url) {
            return Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: const DecorationImage(
                  image: AssetImage('assets/images/placeholder.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: const DecorationImage(
                  image: AssetImage('assets/images/placeholder.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          imageBuilder: (context, imageProvider) {
            return Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        title: Text(channelModel.channelName!),
        subtitle: Text(channelModel.channelDescription!),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(FontAwesomeIcons.circlePlus),
          onPressed: () {
            channelProvider.setRelatedChannel(channelModel.groupId!);
          },
        ),
      ),
    );
  }
}
