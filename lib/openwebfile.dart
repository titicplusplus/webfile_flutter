import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//import 'package:open_file/open_file.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

//import 'package:pdf/pdf.dart';
//import 'package:pdf/widgets.dart' as pw;

//import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

//import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:photo_view/photo_view_gallery.dart';

//import 'package:video_player/video_player.dart';
//import 'package:chewie/chewie.dart';
//import 'package:chewie_prep/chewie_list_item.dart';
//import 'package:video_player/video_player.dart';
import 'package:flowder/flowder.dart';
import 'dart:io';


/**class BottomPage extends StatefulWidget {
  // This will contain the URL/asset path which we want to play

  String url = "";
  String name = "";

  BottomPage({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _BottomPage createState() => _BottomPage();
}**/

class DownloadPage {//State<BottomPage> {

  String name = "";

  DownloadPage() {}

  void setname(String url) {
    name = url.substring( url.lastIndexOf("/") + 1, url.length ); 
  }


  void download_file(String url) async {
		
	final downloaderUtils = DownloaderUtils(
	  progressCallback: (current, total) {},
	  file: File('/storage/emulated/0/Download/${name}'),
	  progress: ProgressImplementation(),
	  onDone: () => print('Download done'),
	  deleteOnCancel: true,
	);

	final core = await Flowder.download(url, downloaderUtils);


  }
  
  String getname() {
       return name;
  }	       

}

class WebView extends StatelessWidget {
  String url = "";
  WebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(url),
      ),
      body: Center(
        child: WebView(
			url: url,
			//javascriptMode: JavascriptMode.unrestricted,
	),

      ),
    );
  }
}

class OpenWebPdf extends StatelessWidget {
  String url = "";
  DownloadPage download = new DownloadPage();
  OpenWebPdf({Key? key, required this.url}) : super(key: key) {
	  download.setname(this.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(download.getname()),
        actions: <Widget>[
	IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'download',
              onPressed: () {
		      download.download_file(url);
              },
            ),
	]
      ),
      body: PDF(
        swipeHorizontal: true,
      ).cachedFromUrl(url),
    );
  }
}




class Gallery extends StatefulWidget {
	Gallery({Key? key, required this.urlimg, required this.urlserver}) : super(key: key);
	List<String> imgList = [];
	String urlimg = "";
	String urlserver = "";


  @override
  _Gallery createState() => _Gallery();
}

class _Gallery extends State<Gallery> {


	PageController _pageController = PageController();//PageController(initialPage: firstPage);

	

	Future<void> requestConnection() async {
		try {
			var url_connection = Uri.parse(widget.urlserver + widget.urlimg);
			var response = await http.get(url_connection);

			if (response.statusCode == 200) {
				String rep = utf8.decode(latin1.encode(response.body), allowMalformed: true);
				widget.imgList = rep.split("\n");
				_pageController.jumpToPage(int.parse(widget.imgList[ widget.imgList.length - 2 ]));

			} else {
				print("error connecting to server");
			}
		}
		finally {
		}
	}

	@override
	void dispose() {
	    _pageController.dispose();
	    super.dispose();
	}

	Widget photo_view() {
		return FutureBuilder(
			future: requestConnection(),

		    	builder: (context, projectSnap) {
		      		if (projectSnap.connectionState == ConnectionState.none &&
			  		projectSnap.hasData == null) {
					return Container();
				}
		      	

				return PhotoViewGallery.builder(
					pageController: _pageController,
					itemCount: widget.imgList.length-2,

					builder: (context, index) {
					  return PhotoViewGalleryPageOptions(
					    imageProvider: NetworkImage(
					      widget.urlserver + widget.imgList[index],
					    ),
					    // Contained = the smallest possible size to fit one dimension of the screen
					    minScale: PhotoViewComputedScale.contained * 1,
					  );
					},

					scrollPhysics: BouncingScrollPhysics(),

					backgroundDecoration: BoxDecoration(
					  color: Theme.of(context).canvasColor,
					),
				); 
			},
		);
	}


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Gallery'),
				actions: <Widget>[
				IconButton(
				      icon: const Icon(Icons.file_download),
				      tooltip: 'download',
				      onPressed: () {
					      int index = (_pageController.page?.round() ?? -1);

					      if (index > -1) {
						      DownloadPage download = new DownloadPage();
						      download.setname(widget.imgList[index]);
						      download.download_file(widget.urlserver + widget.imgList[index]);
					      }
				      },
				    ),
				]
			),
			
			// Implemented with a PageView, simpler than setting it up yourself
			// You can either specify images directly or by using a builder as in this tutorial
			body: photo_view(),
		);
	}
}
