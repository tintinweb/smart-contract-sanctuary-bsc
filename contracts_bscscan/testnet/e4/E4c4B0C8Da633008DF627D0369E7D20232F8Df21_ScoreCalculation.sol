//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract ScoreCalculation {
    struct Survey {
        bytes32[] questions;
        bool[] answers;
    }

    bytes32 private constant RISK_FOUND = keccak256(abi.encodePacked("risk_found"));
    bytes32 private constant MEET_COMMITMENT = keccak256(abi.encodePacked("meet_commitment"));
    bytes32 private constant CHANGE_COMMITMENT = keccak256(abi.encodePacked("change_commitment"));

    bytes32 private constant RISK_EVENT_FOUND = keccak256(abi.encodePacked("risk_event_found"));
    bytes32 private constant NODE_KEEP_UPDATED_FACTORS = keccak256(abi.encodePacked("node_keep_updated_factors"));
    bytes32 private constant ONLY_FOR_POSITIVE = keccak256(abi.encodePacked("only_for_positive"));
    bytes32 private constant ANY_NEGATIVE = keccak256(abi.encodePacked("any_negative"));
    bytes32 private constant COMMUNICATE_BACKUP_PLAN = keccak256(abi.encodePacked("communicate_backup_plan"));

    mapping(bytes32 => mapping(uint128 => Survey)) private visibilitySurveys;
    mapping(bytes32 => mapping(uint128 => Survey)) private commitmentSurveys;

    mapping(bytes32 => uint128[]) private surveyTimestamps;

    function submitSurvey(
        string memory company,
        string[] memory visQuestions, 
        bool[] memory visAnswers, 
        string[] memory comQuestions, 
        bool[] memory comAnswers
    ) public {
        bytes32[] memory encodeVisQuestions;
        bytes32[] memory encodeComQuestions;
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        for (uint256 index = 0; index < visQuestions.length; index++) {
            encodeVisQuestions[index] = keccak256(abi.encodePacked(visQuestions[index]));
        }
        for (uint256 index = 0; index < comQuestions.length; index++) {
            encodeComQuestions[index] = keccak256(abi.encodePacked(comQuestions[index]));
        }
        visibilitySurveys[encodedCompany][uint128(block.timestamp)] = Survey(encodeVisQuestions, visAnswers);
        commitmentSurveys[encodedCompany][uint128(block.timestamp)] = Survey(encodeComQuestions, comAnswers);
        surveyTimestamps[encodedCompany][surveyTimestamps[encodedCompany].length] = uint128(block.timestamp);
    }

    function getCommitmentScore (
        string memory company, 
        uint128 timestamp
    ) public view returns (uint64) {
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        Survey memory survey = commitmentSurveys[encodedCompany][timestamp];
        require(survey.questions.length > 0, "Not found");
        require(survey.questions[0] == RISK_FOUND, "Invalid");
        if (survey.answers[0]) {
            require(survey.questions[1] == CHANGE_COMMITMENT, "Invalid");
            require(survey.questions[2] == MEET_COMMITMENT, "Invalid");
            if (survey.answers[1]) {
                if (survey.answers[2])
                    return 125;
                return 75;
            }  
            if (survey.answers[2])
                return 150;
            return 50;
        }
        require(survey.questions[1] == MEET_COMMITMENT, "Invalid");
        if (survey.answers[1])
            return 105;
        return 95;
    }

    function getVisibilityScore (
        string memory company, 
        uint128 timestamp
    ) public view returns (uint64) {
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        Survey memory survey = visibilitySurveys[encodedCompany][timestamp];
        require(survey.questions.length > 0, "Not found");
        require(survey.questions[0] == RISK_EVENT_FOUND, "Invalid");
        if (survey.answers[0]) {
            require(survey.questions[1] == CHANGE_COMMITMENT, "Invalid");
            require(survey.questions[2] == NODE_KEEP_UPDATED_FACTORS, "Invalid");
            if (survey.answers[1]) {
                if (survey.answers[2]) {
                    require(survey.questions[3] == ONLY_FOR_POSITIVE, "Invalid");
                    if (survey.answers[3]) {
                        require(survey.questions[4] == COMMUNICATE_BACKUP_PLAN, "Invalid");
                        if (survey.answers[4])
                            return 109;
                        return 97;
                    } else {
                        require(survey.questions[4] == ANY_NEGATIVE, "Invalid");
                        if (survey.answers[4])
                            return 106;
                        return 94;
                    }
                }
                return 93;
            } else {
                if (survey.answers[2]) {
                    require(survey.questions[3] == ONLY_FOR_POSITIVE, "Invalid");
                    if (survey.answers[3]) {
                        require(survey.questions[4] == COMMUNICATE_BACKUP_PLAN, "Invalid");
                        if (survey.answers[4])
                            return 112;
                        return 96;
                    } else {
                        require(survey.questions[4] == ANY_NEGATIVE, "Invalid");
                        if (survey.answers[4])
                            return 108;
                        return 92;
                    }
                }
                return 88;
            }
        }
        if (survey.answers[1]) {
            require(survey.questions[2] == ONLY_FOR_POSITIVE, "Invalid");
            if (survey.answers[2]) {
                require(survey.questions[3] == COMMUNICATE_BACKUP_PLAN, "Invalid");
                if (survey.answers[3])
                    return 103;
                return 99;
            } else {
                require(survey.questions[3] == ANY_NEGATIVE, "Invalid");
                if (survey.answers[3])
                    return 102;
                return 98;
            }
        }
        return 87;
    }

    function getCompanyScore(
        string memory company, 
        uint128 timestamp
    ) public view returns (uint64 commitmentScore, uint64 visibilityScore) {
        commitmentScore = getCommitmentScore(company, timestamp);
        visibilityScore = getVisibilityScore(company, timestamp);
    }

    function getCompanySurveyTimestamp(
        string memory company
    ) public view returns (uint128[] memory) {
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        return surveyTimestamps[encodedCompany];
    }
}