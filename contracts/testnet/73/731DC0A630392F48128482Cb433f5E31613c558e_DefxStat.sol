// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

import "./DefxInterfaces.sol";

// DeFX User Statistics contract
contract DefxStat is IDefxStat {
    address public factory;

    constructor() {
        factory = msg.sender;
    }

    modifier onlyPair() {
        require(IDefxFactory(factory).isPair(msg.sender), "DefxFactory: !PAIR");
        _;
    }

    mapping(address => UserProfile) public userProfile;
    mapping(address => mapping(address => bool)) /* from */ /* to */
        public feedbackAllowed;

    function getUserProfile(address account) public view returns (UserProfile memory) {
        return userProfile[account];
    }

    function setFeedbackAllowed(address a, address b) external onlyPair {
        feedbackAllowed[a][b] = true;
        feedbackAllowed[b][a] = true;
    }

    function _setFirstDeal(address account) internal {
        if (userProfile[account].firstDealBlock == 0) {
            userProfile[account].firstDealBlock = block.number;
        }
    }

    function _incrementCompletedDeal(address account) internal {
        userProfile[account].completedDeals++;
        _setFirstDeal(account);
    }

    function _incrementFailedDeal(address account) internal {
        userProfile[account].failedDeals++;
    }

    function incrementCompletedDeal(address a, address b) external onlyPair {
        _incrementCompletedDeal(a);
        _incrementCompletedDeal(b);
    }

    function incrementFailedDeal(address a, address b) external onlyPair {
        _incrementFailedDeal(a);
        _incrementFailedDeal(b);
    }

    function _submitFeedback(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) internal {
        userProfile[to].feedbacks.push(Feedback({isPositive: isPositive, desc: desc, from: from, blockNumber: block.number}));
        feedbackAllowed[from][to] = false;
    }

    function submitFeedback(
        address to,
        bool isPositive,
        string calldata desc
    ) external {
        require(feedbackAllowed[msg.sender][to], "DefxFactory: NOT_ALLOWED");
        _submitFeedback(msg.sender, to, isPositive, desc);
    }

    function submitFeedbackFrom(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) external onlyPair {
        _submitFeedback(from, to, isPositive, desc);
    }

    function setName(string calldata name) external {
        userProfile[msg.sender].name = name;
    }

    function setSocialAccounts(string calldata data) external {
        userProfile[msg.sender].socialAccounts = data;
    }

    function setUserProfile(string calldata name, string calldata socialAccounts) external {
        userProfile[msg.sender].name = name;
        userProfile[msg.sender].socialAccounts = socialAccounts;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

// ---------- LIBRATIES ----------

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
}

// --------- TYPES & CONSTANTS -------

uint256 constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

struct Message {
    string encryptedForSeller;
    string encryptedForBuyer;
    address from;
}

struct Deal {
    uint256 amountCrypto;
    uint256 collateral;
    uint256 amountFiat;
    bool isBuyerOwner;
    string paymentMethod;
    Message[] messages;
    bool fiatSent;
    uint256 bankSentAtBlock;
}

struct Offer {
    uint256 min;
    uint256 max;
    uint256 available;
    uint256 collateral;
    uint256 price;
    string[] paymentMethods;
    string desc;
    uint256 ratio;
    uint256 lastUpdatedBlock;
}

struct DealLinks {
    mapping(address => address[]) buyers;
    mapping(address => address[]) sellers;
}

struct CreateOfferParams {
    address _cryptoAddress;
    bool _isBuy;
    uint256 _deposit;
    uint256 _available;
    uint256 _min;
    uint256 _max;
    uint256 _price;
    uint256 _ratio;
    string[] _paymentMethods;
    string _desc;
}

struct MatchParams {
    address factory;
    address cryptoAddress;
    address owner;
    bool isBuy;
    uint256 amountCrypto;
    string paymentMethod;
}

struct UserProfile {
    string name;
    string socialAccounts;
    uint256 completedDeals;
    uint256 failedDeals;
    uint256 firstDealBlock;
    Feedback[] feedbacks;
}

struct Feedback {
    bool isPositive;
    string desc;
    address from;
    uint256 blockNumber;
}

// ---------- INTERFACES ---------

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IDefxFactory {
    event PairCreated(address cryptoAddress, string fiatAddress, address pair, uint256);

    function getPair(address tokenA, string memory fiatAddress) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function encKeys(address account) external view returns (string memory);

    function isPair(address pairAddr) external view returns (bool);

    function statAddress() external view returns (address);

    function setAllowedCoin(address _coinAddress) external;
}

interface IDefxPair {
    function initialize(address, string memory) external;
}

interface IDefxStat {
    function getUserProfile(address account) external view returns (UserProfile memory);

    function setFeedbackAllowed(address a, address b) external;

    function incrementCompletedDeal(address a, address b) external;

    function incrementFailedDeal(address a, address b) external;

    function submitFeedback(
        address to,
        bool isPositive,
        string calldata desc
    ) external;

    function submitFeedbackFrom(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) external;

    function setName(string calldata name) external;

    function setSocialAccounts(string calldata data) external;
}

interface IDefxToken {
    function decimals() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function burnAll() external;

    function burn(uint256 amount) external;
}

interface IERC20 {
    function decimals() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}