package controllers;

import play.mvc.*;

public class HomeController extends Controller {

    public Result index(Http.Request request) {
        String timestamp = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
        String ipAddress = request.remoteAddress();
        return ok(views.html.main.render(timestamp, ipAddress));
    }

    public Result health() {
        return ok("health ok");
    }
}
