package controllers;

import play.mvc.*;
import java.net.InetAddress;

public class HomeController extends Controller {

    public Result index(Http.Request request) {
        String timestamp = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
        String clientIpAddress = request.remoteAddress();
        String serverIpAddress = getServerIpAddress();
        return ok(views.html.main.render(timestamp, clientIpAddress, serverIpAddress));
    }

    private String getServerIpAddress() {
        try {
            InetAddress localHost = InetAddress.getLocalHost();
            return localHost.getHostAddress();
        } catch (Exception e) {
            return "Unable to determine server IP";
        }
    }

    public Result health() {
        return ok("health ok");
    }
}
