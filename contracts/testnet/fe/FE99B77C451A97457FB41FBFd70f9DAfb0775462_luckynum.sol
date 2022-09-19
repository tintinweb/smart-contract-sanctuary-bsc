// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
//import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
//import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./VRFCoordinatorV2Interface.sol";
import ".//VRFConsumerBaseV2.sol";
library Strings {
    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function slice(uint begin, string memory text) internal pure returns (string memory) {
        require(begin % 5 == 1 && begin < 72, "input illegal" );
        uint end = begin + 4;
        bytes memory a = new bytes(end - begin + 1);
        for(uint i=0; i<= end - begin; i++) {
            a[i] = bytes(text)[i + begin - 1];
        }
        return string(a);
    }
}

contract luckynum is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    uint32 callbackGasLimit = 2000000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  62;
    uint256[] private s_randomWords;
    uint256 private s_requestId;

    mapping(bytes32 => mapping(address => bool)) private roles;
    bytes32 private constant ADMIN = keccak256(abi.encode("ADMIN"));
    mapping(uint => bytes32) public Hash;
    mapping(uint => mapping(bytes32 => string)) public OpenCode;
    uint private lastChange = block.timestamp;
    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _;
    }
    modifier onlyAfter(uint _time) {
        require(block.timestamp >= _time, 'not allowed');
        _;
    }
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        _grantRole(ADMIN, msg.sender);
    }

    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true;
    }

    function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        _grantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        roles[_role][_account] = false;
    }

    function getHash(string memory _str) public pure returns(bytes32) {
        return keccak256(abi.encode(_str));
    }

    function requestRandomWords() external onlyRole(ADMIN) {
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }
  
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function generateResult(uint input, uint expectno, uint indexnum) external onlyRole(ADMIN) onlyAfter(lastChange + 60 seconds){
        string memory text = Strings.toString(s_randomWords[indexnum]);
        if(input > 5){
            Hash[expectno] = getHash(Strings.slice(input, text));
            OpenCode[expectno][Hash[expectno]] = Strings.slice(input - 5, text);
        }
        else if(input == 1 && indexnum >= 1){
            string memory text0 = Strings.toString(s_randomWords[indexnum - 1]);
            Hash[expectno] = getHash(Strings.slice(input, text));
            OpenCode[expectno][Hash[expectno]] = Strings.slice(71, text0);   
        }else{
            Hash[expectno] = getHash(Strings.slice(input, text));
        }
        lastChange = block.timestamp;
    }

    function result_hash(uint expectno) external view returns(bytes32){
        return Hash[expectno];
    }

    function result_opencode(uint expectno) external view returns(string memory){
        return OpenCode[expectno][Hash[expectno]];
    }
}