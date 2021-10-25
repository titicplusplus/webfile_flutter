import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:webview_flutter/webview_flutter.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';

//import 'package:pdf/pdf.dart';
//import 'package:pdf/widgets.dart' as pw;

//import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
//import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path/path.dart' as p;

import 'openwebfile.dart';


void main() async {
	/**if (prefs.getString("ip_addr") ?? 0 == 0) {
		runApp(ConnectionMenuForm());
	}
	else {
		List<String> result = prefs.getString().split('\n');
		runApp(MyApp(url: myController.text)); 
	}**/


	runApp(ConnectionMenuForm());

	//SharedPreferences.setMockInitialValues({});

	Preferences_webfile web = Preferences_webfile();
	await web.init();

	if (web.getdefault() != "") {
		runApp(MyApp(url: web.getdefault())); 
	}
	else runApp(ConnectionMenuForm());
}

class Preferences_webfile {
	//var prefs;
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	List<String> url_list = [];
	String url_prio = "";

	Preferences_webfile() {}

	Future<void> init() async {
		final SharedPreferences prefs = await _prefs;
		//prefs = await SharedPreferences.getInstance();
		url_list = prefs.getStringList("ip_addr") ?? [];
		url_prio = prefs.getString("ip_prio") ?? "";
	}


	Future<void> add_element(String url) async {
		final SharedPreferences prefs = await _prefs;
		url_list.add(url); 
		prefs.setStringList("ip_addr", url_list);
	}

	Future<void> define_prio(String url) async {
		final SharedPreferences prefs = await _prefs;

		if (url != url_prio)
		{
			if (!url_list.contains(url)) {
				add_element(url);
			}
			url_prio = url;
			prefs.setString("ip_prio", url_prio);
		}

		//print(await prefs.getStringList("ip_addr") ?? []);
	}

	int getSize() {
		return url_list.length;
	}

	String getIP(int index) => url_list[index];

	String getdefault() {
		if (url_prio != "") {
			return url_prio;
		}
		else if (url_list.length != 0)
		{
			return url_list[0];
		}

		return "";
	}

	Future<void> remove_element(int element) async {
		final SharedPreferences prefs = await _prefs;
		url_list.removeAt(element);
		prefs.setStringList("ip_addr", url_list);
	}

}

class ConnectionMenuForm extends StatefulWidget {
  Preferences_webfile data_w = Preferences_webfile();

  ConnectionMenuForm({Key? key}) : super(key: key) {
	  data_w.init();
  }

  @override
  _ConnectionMenu createState() => _ConnectionMenu();
}

class _ConnectionMenu extends  State<ConnectionMenuForm> {
  final myController = TextEditingController();

  _ConnectionMenu() {
  }

  /**void init() async {
	data_w.init();
  }**/

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  bool requestConnection(String url) {

	  widget.data_w.add_element(myController.text);

	  widget.data_w.define_prio(myController.text);

	  print("Requesting url: " + url);
	  return true;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebFile',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebFile'),
        ),
        body: Column(
	  //mainAxisAlignment: MainAxisAlignment.center,
  	  //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),
            Text(
              'Connection to web file server',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Center(
              //constraints: BoxConstraints(minWidth: 100, maxWidth: 900),
	      //textAlign: TextAlign.center,
              child: Container(
		      constraints: BoxConstraints(minWidth: 100, maxWidth: 900, minHeight: 100, maxHeight: 1900),
		      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
		      child: TextFormField(
			onFieldSubmitted: (value) {
				if (requestConnection(myController.text))
			  	{
			 		runApp(MyApp(url: myController.text)); 
				}
  			},
			controller: myController,
			decoration: const InputDecoration(
			    border: UnderlineInputBorder(),
			    labelText: 'IP address for web file (http://ip:port)'),
		      ),
		    ),
	    ),
            SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                //padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              ),
              child: Text(
                "Connection",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              onPressed: () {

		  if (requestConnection(myController.text))
		  {
			 runApp(MyApp(url: myController.text)); 
		  }
	      },
            ),
	    SizedBox(height: 50),
	    const Text(
              'Old connection',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
	    ListView.builder(
			    scrollDirection: Axis.vertical,
    			    shrinkWrap: true,
			    padding: const EdgeInsets.all(8),
			    itemCount: widget.data_w.getSize(),
			    itemBuilder: (BuildContext context, int index) {
				    return Row(
						mainAxisAlignment: MainAxisAlignment.center, //Center Column contents vertically,
						children: <Widget>[
							TextButton(
									child: Text(
											widget.data_w.getIP(index),
											style: TextStyle(
													fontSize: 18,
											),
									),
									onPressed: () {
										widget.data_w.define_prio(widget.data_w.getIP(index));
										runApp(MyApp(url: widget.data_w.getIP(index)));
									},
							),
							IconButton(
									icon: const Icon(Icons.delete),
									
									onPressed: () async {
										await widget.data_w.remove_element(index);
										setState( () {} );
									},
							),
						],
						    
				    );
		    },
	    ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final String url;
  const MyApp ({ Key? key, required this.url }): super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> { // StatelessWidget {

  //final String url;
  //_MyApp({Key? key, required this.url}): super(key: key) {}

  var list_ff = [];
  int grid_mod = 1;
  bool refresh_body = true;
  String folder_name = "";

  String folder = "";


  Future<bool> requestConnection(String folder_new) async {
	try {
		var url_connection = Uri.parse(widget.url + "/dir_api/" + folder_new);
		var response = await http.get(url_connection);

		if (response.statusCode == 200) {
			String rep = utf8.decode(latin1.encode(response.body), allowMalformed: true);
			list_ff = rep.split("\n");
		} else {
			print("error connecting to server");
			return false;
		}
	}
	finally {
	}

	folder = folder_new;

	setState( () {} );
	refresh_body = false;
	return true;
  }

  bool list_ff_to_body() {
	  return true;
  }

  void _launchURL(url_file) async =>
    await canLaunch(url_file) ? await launch(url_file) : throw 'Could not launch $url_file';

  void pressKey(int Index, bool ff_, BuildContext context) {
	if (ff_) {
		//if (Platform.isAndroid || Platform.isIOS) {
		if ((defaultTargetPlatform == TargetPlatform.iOS) || (defaultTargetPlatform == TargetPlatform.android)) {
			String url = widget.url + list_ff[Index*3+1];
			final ext = p.extension(url).toLowerCase();
			print("The url is $url with extension $ext");

			if (ext == ".pdf") {
				Navigator.push(
				    context,
				    MaterialPageRoute(builder: (context) => OpenWebPdf(url: url)),
				  );
			}
			/**else if (ext == ".mp3" || ext == ".avi" || ext == ".mp3" || ext == ".m4a" || 
				ext == ".fmp4" || ext == ".WebM" || ext == ".ogg" || ext == ".wav" || 
				ext == ".flv" || ext == ".flac" || ext == ".amr") {
				Navigator.push(
				    context,
				    MaterialPageRoute(builder: (context) => OpenWebVideo()),
				  );
			}**/
			else if (ext == ".png" || ext == ".PNG" || 
					ext == ".jpg" ||
					ext == ".JPG" || ext == ".jpeg" || ext == ".JPEG" || ext == ".gif" ||
					ext == ".GIF")
			{
				String url_2 = "/img_api/" + list_ff[Index*3+1].substring(10);
				Navigator.push(
				    context,
				    MaterialPageRoute(builder: (context) => Gallery(urlserver: widget.url,
								    urlimg: url_2)),
				);
				 
			}
			else {
				//OpenFile.open(url);
				//_launchURL( widget.url + list_ff[Index*3+1]);
				/**Navigator.push(
				    context,
				    MaterialPageRoute(builder: (context) => WebView(url: url)),
				);**/
			}
				 
			//OpenFile.open(url);
			/**Navigator.push(
			      context,
			      MaterialPageRoute<dynamic>(
				builder: (_) => const PDFViewerFromUrl(
				  url: 'http://africau.edu/images/default/sample.pdf',
				),
			      ),
			    );**/
		}	
		else {
			_launchURL( widget.url + list_ff[Index*3+1]);
		}
	}
	else {
		folder_name = list_ff[Index*3];
		requestConnection( folder + list_ff[Index*3] + "/"); 
	}
  }

  @override
  Widget build(BuildContext context) {
	  
    if (refresh_body) {
	    requestConnection("");
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebFile',
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
		    if (folder.length > 2) {
			    int size = folder.length;
			    if (folder[size-1] == '/') {
				    folder = folder.substring(0, size-1);
			    }
			    
			    folder = folder.substring( 0,  folder.lastIndexOf('/')+1) ;
		    	    folder_name = folder;

			    if (folder != "") {
				    try {
					    folder_name = folder.substring(0, folder.length-1);
					    folder_name = folder_name.substring( folder_name.lastIndexOf('/')+1, folder_name.length) ;
					    print("Second $folder_name");
				    } catch(e) { 
					    folder_name = "";
				    }
			    }
			    else {
				    folder_name = widget.url;
			    }

		    }
		    else {
			    folder = "";
		    }

		    requestConnection(folder);
            },
          ),
          title: const Text('WebFile'),
          actions: <Widget>[
            /**IconButton(
              icon: const Icon(Icons.view_module),
              tooltip: 'Mosaïque',
              onPressed: () {
                // handle the press
		grid_mod = 2;
		setState( () {} );
              },
            ),**/
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Connection Server',
              onPressed: () {
                // handle the press
		//grid_mod = 1;
		//setState( () {} );
		runApp(ConnectionMenuForm());
              },
            ),
	    IconButton(
              //icon: const Icon(Icons.view_module),
              icon: Icon( (grid_mod == 1) ? Icons.view_module:Icons.view_list),
              tooltip: 'Change mode',
              onPressed: () {
                // handle the press
		if (grid_mod == 1)
			grid_mod = 2;
		else grid_mod = 1;
		setState( () {} );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Home',
              onPressed: () {
		      folder_name = "";
		      requestConnection("");
              },
            ),
          ],
        ),
        body: Column (
			children: <Widget>[
				new Expanded(
						child: StaggeredGridView.countBuilder(


								padding: const EdgeInsets.all(8),
								itemCount: (list_ff.length/3).round(),

								key: ObjectKey(grid_mod),
								crossAxisCount: grid_mod,
								mainAxisSpacing: 4.0,
  								crossAxisSpacing: 4.0,

								//itemExtent: 70.0,
								
								/**gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: grid_mod,
									childAspectRatio: 300 / 200,
									),//, childAspectRatio: 10/(grid_mod*2)),**/



								itemBuilder: (BuildContext ctxt, int Index) {
									//return new Text(list_ff[Index*3]);
									bool open_file_web = true;

									if ("/icon/folder.png" == list_ff[Index*3+2]) {
										open_file_web = false;
									}

									if (grid_mod == 2) {
										String url_img = widget.url;

										if ("/icon/jpg.png" == list_ff[Index*3+2] || "/icon/png.png" == list_ff[Index*3+2]) {
											url_img += list_ff[Index*3+1];
										}
										else {
											url_img += list_ff[Index*3+2];
										}

										return new Container(
											margin: const EdgeInsets.only(top: 3.0, bottom: 3.0),

											/**child: TextButton(
											    style: TextButton.styleFrom(
											      textStyle: const TextStyle(fontSize: 20),
											    ),
											    onPressed: () {},
											    child: Text(list_ff[Index*3]),
											    icon
											  ),**/
											  child: RaisedButton(
											    onPressed: () {
												pressKey(Index, open_file_web, ctxt);
												/**if (open_file_web) {
													if (Platform.isAndroid || Platform.isIOS) {

													}
													else {
													}
													
												}
												else {
													requestConnection( folder + list_ff[Index*3] + "/"); 
												}**/
											    },
											    color: Colors.white,
											    child: Column(
											      children: <Widget>[
												//Icon(),
											        Image.network(
														url_img,
														height: 100,
														),
												SizedBox(width: 50),
												Text(list_ff[Index*3], style: TextStyle(color: Colors.blue),),
											      ],
											    ),
											  ),
										);
									}

									return new Container(
											margin: const EdgeInsets.only(top: 3.0, bottom: 3.0),
											height: 50,

											  child: RaisedButton(
											    onPressed: () {
											   	//requestConnection( folder + list_ff[Index*3] + "/"); 
												pressKey(Index, open_file_web, ctxt);
												
											    },
											    color: Colors.white,
											    child: Row(
											      children: <Widget>[
												//Icon(),
											        Image.network(
														widget.url + list_ff[Index*3+2],
														height: 50,
														width: 50,
														),
												SizedBox(width: 50),
												Text(list_ff[Index*3], style: TextStyle(color: Colors.blue),),
											      ],
											    ),
											  ),
										);
									//);
								},


								staggeredTileBuilder: (int index) =>
      									//new StaggeredTile.count(1, index.isEven ? 1 : 1),
									StaggeredTile.fit(1),
								//separatorBuilder: (BuildContext context, int index) => const Divider(),
						),
				),
			],

		),

		bottomSheet: Container(
			height: 30,
			child: AppBar(
			  centerTitle: true,
			  title: Text( folder_name ),
			),

		),
		),


    );
  }
}
