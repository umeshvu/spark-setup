package com.uuhere.sparktest.api;

import com.uuhere.sparktest.service.CsvSortJob;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class JobController {

    private final CsvSortJob job;

    public JobController(CsvSortJob job) {
        this.job = job;
    }

    @GetMapping("/run-job")
    public String runJob() {
        String inputPath = "/data/input.csv";
        String outputPath = "/data/output";

        job.runJob(inputPath, outputPath);
        return "Job submitted! Input=" + inputPath + " Output=" + outputPath;
    }
}
