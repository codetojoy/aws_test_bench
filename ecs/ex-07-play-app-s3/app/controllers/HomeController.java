package controllers;

import play.mvc.*;
import com.typesafe.config.Config;
import javax.inject.Inject;

import java.net.InetAddress;

public class HomeController extends Controller {
    private static final String FOOBAR_KEY = "net.codetojoy.foobar";

    private final Config config;

    @Inject
    public HomeController(Config config) {
        this.config = config;
    }

    public Result index(Http.Request request) {
        String timestamp = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
        String clientIpAddress = request.remoteAddress();
        String serverIpAddress = getServerIpAddress();
        String foobarValue = getConfigValue(FOOBAR_KEY);
        return ok(views.html.main.render(timestamp, clientIpAddress, serverIpAddress, foobarValue));
    }

    public Result health() {
        return ok("health ok");
    }

    // ------------------------------------------

    private String getServerIpAddress() {
        try {
            InetAddress localHost = InetAddress.getLocalHost();
            return localHost.getHostAddress();
        } catch (Exception e) {
            return "Unable to determine server IP";
        }
    }

    private String getConfigValue(String key) {
        if (config.hasPath(key)) {
            return config.getString(key);
        } else {
            return "no such key";
        }
    }
}
