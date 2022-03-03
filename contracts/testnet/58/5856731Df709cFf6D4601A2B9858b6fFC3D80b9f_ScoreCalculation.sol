//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract ScoreCalculation is Ownable {
    struct Survey {
        uint256 timestamp;
        bytes32[] questions;
        bool[] answers;
        address creator;
    }

    bytes32 private constant RISK_FOUND = keccak256(abi.encodePacked("risk_found"));
    bytes32 private constant MEET_COMMITMENT = keccak256(abi.encodePacked("meet_commitment"));
    bytes32 private constant CHANGE_COMMITMENT = keccak256(abi.encodePacked("change_commitment"));

    bytes32 private constant RISK_EVENT_FOUND = keccak256(abi.encodePacked("risk_event_found"));
    bytes32 private constant NODE_KEEP_UPDATED_FACTORS = keccak256(abi.encodePacked("node_keep_updated_factors"));
    bytes32 private constant ONLY_FOR_POSITIVE = keccak256(abi.encodePacked("only_for_positive"));
    bytes32 private constant ANY_NEGATIVE = keccak256(abi.encodePacked("any_negative"));
    bytes32 private constant COMMUNICATE_BACKUP_PLAN = keccak256(abi.encodePacked("communicate_backup_plan"));

    mapping(bytes32 => mapping(uint256 => Survey[])) public visibilitySurveys;
    mapping(bytes32 => mapping(uint256 => Survey[])) public commitmentSurveys;

    mapping(bytes32 => uint256[]) public contractIds;

    function submitSurvey(
        string memory company,
        uint256 contractId,
        string[] memory visQuestions, 
        bool[] memory visAnswers, 
        string[] memory comQuestions, 
        bool[] memory comAnswers
    ) public onlyOwner {
        bytes32[] memory encodeVisQuestions = new bytes32[](visQuestions.length);
        bytes32[] memory encodeComQuestions = new bytes32[](comQuestions.length);
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        for (uint256 index = 0; index < visQuestions.length; index++) {
            encodeVisQuestions[index] = keccak256(abi.encodePacked(visQuestions[index]));
        }
        for (uint256 index = 0; index < comQuestions.length; index++) {
            encodeComQuestions[index] = keccak256(abi.encodePacked(comQuestions[index]));
        }
        visibilitySurveys[encodedCompany][contractId].push(Survey(block.timestamp, encodeVisQuestions, visAnswers, msg.sender));
        commitmentSurveys[encodedCompany][contractId].push(Survey(block.timestamp, encodeComQuestions, comAnswers, msg.sender));
        bool duplicated = false;
        for (uint256 index = 0; index < contractIds[encodedCompany].length; index++) {
            if (contractIds[encodedCompany][index] == contractId) {
                duplicated = true;
                break;
            }
        }
        if (!duplicated) {
            contractIds[encodedCompany].push(contractId);
        }
    }

    function calculateCommitmentScore(Survey memory survey) private pure returns(uint64) {
        if (survey.questions.length == 0)
            return 2;
        if (survey.questions[0] != RISK_FOUND)
            return 3;
        if (survey.answers[0]) {
            if (survey.questions[1] != CHANGE_COMMITMENT)
                return 4;
            if (survey.questions[2] != MEET_COMMITMENT)
                return 5;
            if (survey.answers[1]) {
                if (survey.answers[2])
                    return 125;
                return 75;
            }  
            if (survey.answers[2])
                return 150;
            return 50;
        }
        if (survey.questions[1] != MEET_COMMITMENT)
            return 6;
        if (survey.answers[1])
            return 105;
        return 95;
    }

    function getCommitmentScore (
        string memory company,
        uint256 contractId,
        uint256 timestamp
    ) public view returns (uint64) {
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        Survey[] memory surveys = commitmentSurveys[encodedCompany][contractId];
        uint64 count = 0;
        uint64 sum = 0;
        for (uint256 index = 0; index < surveys.length; index++) {
            if((surveys[index].timestamp/(1 days))*(1 days) == timestamp) {
                count++;
                sum += calculateCommitmentScore(surveys[index]);
            }
        }
        if (count == 0)
            return 0;
        return sum/count;
    }

    function calculateVisibilityScore(Survey memory survey) private pure returns(uint64) {
        if (survey.questions.length == 0)
            return 2;
        if (survey.questions[0] != RISK_EVENT_FOUND)
            return 3;
        if (survey.answers[0]) {
            if (survey.questions[1] != CHANGE_COMMITMENT)
                return 4;
            if (survey.questions[2] != NODE_KEEP_UPDATED_FACTORS)
                return 5;
            if (survey.answers[1]) {
                if (survey.answers[2]) {
                    if (survey.questions[3] != ONLY_FOR_POSITIVE)
                        return 6;
                    if (!survey.answers[3]) {
                        if (survey.questions[4] != COMMUNICATE_BACKUP_PLAN)
                            return 7;
                        if (survey.answers[4])
                            return 109;
                        return 97;
                    } else {
                        if (survey.questions[4] != ANY_NEGATIVE)
                            return 8;
                        if (!survey.answers[4])
                            return 106;
                        return 94;
                    }
                }
                return 91;
            } else {
                if (survey.answers[2]) {
                    if (survey.questions[3] != ONLY_FOR_POSITIVE)
                        return 9;
                    if (!survey.answers[3]) {
                        if (survey.questions[4] != COMMUNICATE_BACKUP_PLAN)
                            return 10;
                        if (survey.answers[4])
                            return 112;
                        return 96;
                    } else {
                        if (survey.questions[4] != ANY_NEGATIVE)
                            return 11;
                        if (!survey.answers[4])
                            return 108;
                        return 92;
                    }
                }
                return 88;
            }
        }
        if (survey.answers[1]) {
            if (survey.questions[2] != ONLY_FOR_POSITIVE)
                return 12;
            if (!survey.answers[2]) {
                if (survey.questions[3] != COMMUNICATE_BACKUP_PLAN)
                    return 13;
                if (survey.answers[3])
                    return 103;
                return 99;
            } else {
                if (survey.questions[3] != ANY_NEGATIVE)
                    return 14;
                if (!survey.answers[3])
                    return 102;
                return 98;
            }
        }
        return 97;
    }

    function getVisibilityScore (
        string memory company, 
        uint256 contractId,
        uint256 timestamp
    ) public view returns (uint64) {
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        Survey[] memory surveys = visibilitySurveys[encodedCompany][contractId];
        uint64 count = 0;
        uint64 sum = 0;
        for (uint256 index = 0; index < surveys.length; index++) {
            if((surveys[index].timestamp/(1 days))*(1 days) == timestamp) {
                count++;
                sum += calculateVisibilityScore(surveys[index]);
            }
        }
        if (count == 0)
            return 0;
        return sum/count;
    }

    function getCompanyScoreByContractId(
        string memory company, 
        uint256 contractId,
        uint256 timestamp
    ) public view returns (uint64) {
        uint64 commitmentScore = getCommitmentScore(company, contractId, timestamp);
        uint64 visibilityScore = getVisibilityScore(company, contractId, timestamp);
        return commitmentScore + visibilityScore - 100;
    }

    function getCompanySurveyByTimestamp(
        string memory company,
        uint256 timestamp
    ) public view returns (uint64) {
        bytes32 encodedCompany = keccak256(abi.encodePacked(company));
        uint256[] memory companyContractIds = contractIds[encodedCompany];
        uint64 count = 0;
        uint64 sum = 0;
        for (uint256 index = 0; index < companyContractIds.length; index++) {
            uint64 score = getCompanyScoreByContractId(company, companyContractIds[index], timestamp);
            if (score != 0) {
                sum += score;
                count += 1;
            }
            
        }
        if (count == 0)
            return 0;
        return sum/count;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}