package com.labuanservices.suara;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "saura.biz/deeplinks";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                if(methodCall.method.equals("openWazeClientApp")){
                  String latitude = methodCall.argument("latitude");
                  String longitude = methodCall.argument("longitude");
                  int progress = openWazeClientApp(latitude,longitude);
                  if(progress != -1){
                    result.success("success");
                  }else{
                    result.error("UNAVAILABLE","App not installed",null);
                  }
                }else{
                  result.notImplemented();
                }
              }
            }
    );
  }

  private int openWazeClientApp(String lat, String lon){
    int result = 0;

    try{
      // Launch Waze for a specific location:
      String url = "https://waze.com/ul?ll="+lat+","+lon+"&z=10";
      Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
      startActivity(intent);
    }catch(Exception ex){
      // If Waze is not installed, open it in Google Play:
      Intent intent = new Intent( Intent.ACTION_VIEW, Uri.parse( "market://details?id=com.waze" ) );
      startActivity(intent);
      result = -1;
    }

    return result;
  }
}
