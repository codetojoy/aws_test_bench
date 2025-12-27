package controllers;

import play.mvc.Controller;
import play.mvc.Result;

public class HomeController extends Controller {

    private String buildLog(String message) {
        return "TRACER Play app :: [" + new java.util.Date() + "] :: " + message;
    }

    public Result index() {
        return ok(buildLog("hello from webapp"));
    }

    public Result health() {
        return ok(buildLog("health ok"));
    }
}
