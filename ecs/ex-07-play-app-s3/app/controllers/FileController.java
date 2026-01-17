package controllers;

import models.FileInfo;
import play.mvc.*;
import services.FileService;

import javax.inject.Inject;
import java.util.List;

public class FileController extends Controller {
    private final FileService fileService;

    @Inject
    public FileController(FileService fileService) {
        this.fileService = fileService;
    }

    public Result listFiles(Http.Request request) {
        List<FileInfo> files = fileService.listFiles();
        String bucketName = fileService.getBucketName();
        return ok(views.html.files.render(files, bucketName));
    }
}
