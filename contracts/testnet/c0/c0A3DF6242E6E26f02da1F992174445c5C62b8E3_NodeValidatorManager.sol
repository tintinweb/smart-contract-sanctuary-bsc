/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

library SignatureUtil {

    error SignatureInvalidV();
    error SignatureInvalidLength();

    function _countSignatures(bytes memory _signatures) internal pure returns (uint256) {
        return _signatures.length % 65 == 0 ? _signatures.length / 65 : 0;
    }

    function getUnsignedMsg(bytes32 _submissionId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _submissionId));
    }

    function splitSignature(bytes memory _signature) internal pure returns (bytes32 r, bytes32 s, uint8 v){
        if (_signature.length != 65) revert SignatureInvalidLength();
        return parseSignature(_signature, 0);
    }

    function parseSignature(bytes memory _signatures, uint256 offset) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        assembly {
            r := mload(add(_signatures, add(32, offset)))
            s := mload(add(_signatures, add(64, offset)))
            v := and(mload(add(_signatures, add(65, offset))), 0xff)
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) revert SignatureInvalidV();
    }
}

interface  INodeValidatorManager {
    
    function verify(bytes32 _submisstionId, uint8 _excessConfirmations, bytes memory _proofs) external;
}

contract NodeValidatorManager is INodeValidatorManager {

    using SignatureUtil for bytes;
    using SignatureUtil for bytes32;

    struct Validator {
        address account;
        bool isValid; 
        bool required;
        uint256 numberOfConfirmations;
    }

    /* ========== STATE VARIABLES ========== */

    uint8 public requiredValidatorsCount;

    mapping(address => Validator) public getValidators;

    address public pendingAdmin;
    address public admin;
    address public bridgeAddress;

    uint256 public totalNodes;
    
    constructor(
        address _admin, 
        address _bridgeAddress,
        uint8 _requiredValidatorsCount
        ) {
        admin = _admin;
        bridgeAddress = _bridgeAddress;
        requiredValidatorsCount = _requiredValidatorsCount;
    }


    /* ========== ERROR ========== */
    error DuplicateSignatures();
    error NotConfirmedByRequiredNodes();
    error NotConfirmedThreshold();
    error SubmissionNotConfirmed();
    error NotValidProof();
    error BridgeBadRole();
    error AdminBadRole();
    error PendingAdminBadRole();


    /* ========== EVENT ========== */    
    event SubmissionApproved(bytes32 msgHash);



    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        if (msg.sender != admin) revert AdminBadRole();
        _;
    }

    modifier onlyPendingAdmin() {
        if (msg.sender != pendingAdmin) revert PendingAdminBadRole();
        _;
    }

    modifier onlyBridge() {
        if (msg.sender != bridgeAddress) revert BridgeBadRole();
        _;
    }
    

    /* ========== INTERNAL ========== */

    function _verify(bytes32 _msgHash, bytes memory _proofs) internal returns  (uint256 currentRequiredNodesCount, uint8 confirmations) {
        uint256 signaturesCount = _proofs._countSignatures();
        address[] memory validators = new address[](signaturesCount);
        for(uint256 i = 0; i < signaturesCount; i++) {
            (bytes32 r, bytes32 s, uint8 v) = _proofs.parseSignature(i * 65);
            address validatorAddress = ecrecover(_msgHash.getUnsignedMsg(), v, r, s);
            Validator storage validator = getValidators[validatorAddress];
            if (validator.isValid == true) {
                for (uint256 k = 0; k < i; k++) {
                    if (validators[k] == validatorAddress) revert DuplicateSignatures();
                }
                validators[i] = validatorAddress;

                confirmations += 1;
                if (validator.required) {
                    currentRequiredNodesCount += 1;
                }

                validator.numberOfConfirmations += 1;
                getValidators[validatorAddress] = validator;
            } else {
                revert NotValidProof();
            }
        }

        return (currentRequiredNodesCount, confirmations);
    }

    function IsValidSignature(bytes32 _submissionId, bytes memory _signature) external view returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = _signature.splitSignature();
        address validator = ecrecover(_submissionId.getUnsignedMsg(), v, r, s);
        return getValidators[validator].isValid;
    }
    

    /* ========== External ========== */
    function verify(bytes32 _submisstionId, uint8 _excessConfirmations, bytes memory _proofs) external override onlyBridge {

        (uint256 currentRequiredNodesCount, uint8 confirmations) = _verify(_submisstionId, _proofs);

        if (currentRequiredNodesCount < requiredValidatorsCount)
            revert NotConfirmedByRequiredNodes();

        uint256 halfTotal = (totalNodes / 2) + 1;

        if (confirmations < _excessConfirmations || confirmations < halfTotal) revert SubmissionNotConfirmed();


        emit SubmissionApproved(_submisstionId);
    }

    function UpdateRequiredNodesVerify(uint8 _requiredValidatorsCount) external onlyAdmin {
        requiredValidatorsCount = _requiredValidatorsCount;
    }

    function AddUpdateNode(Validator memory validator) external onlyAdmin {
        if(!getValidators[validator.account].isValid) {
            totalNodes += 1;
        }
        getValidators[validator.account] = validator;
    }

    function RemoveNode(Validator memory validator) external onlyAdmin {
        delete getValidators[validator.account];
        totalNodes -= 1;
    }

    function UpdateBridgeAddress(address _bridgeAddress) external onlyAdmin {
        bridgeAddress = _bridgeAddress;
    }

    function UpdateAdminAddress(address _admin) external onlyAdmin {
        pendingAdmin = _admin;
    }

    function ConfirmAdmin() external onlyPendingAdmin {
        delete pendingAdmin;
        admin = msg.sender;
    }
}