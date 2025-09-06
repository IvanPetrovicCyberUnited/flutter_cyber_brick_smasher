.PHONY: securityAll qualityAll

securityAll:
	gradle dependencyCheckAnalyze cyclonedxBom spotbugsMain checkstyleMain pmdMain pitest

qualityAll:
	gradle clean test jacocoTestReport
