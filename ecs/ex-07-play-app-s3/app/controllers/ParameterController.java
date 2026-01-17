package controllers;

import models.ParameterInfo;
import play.mvc.*;
import services.ParameterService;

import javax.inject.Inject;
import java.util.List;

public class ParameterController extends Controller {
    private final ParameterService parameterService;

    @Inject
    public ParameterController(ParameterService parameterService) {
        this.parameterService = parameterService;
    }

    public Result getParameterValues(Http.Request request) {
        List<ParameterInfo> parameters = parameterService.getParameterValues();
        return ok(views.html.parameters.render(parameters));
    }
}
