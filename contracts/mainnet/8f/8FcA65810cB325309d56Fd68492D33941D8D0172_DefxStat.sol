// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "./DefxInterfaces.sol";

// DeFX User Statistics contract
contract DefxStat is IDefxStat {
    address public factory;

    constructor() {
        factory = msg.sender;
    }

    modifier onlyDefxContracts() {
        require(IDefxFactory(factory).getIsPairOrDispute(msg.sender), "DefxFactory: ONLY_DEFX_CONTRACTS");
        _;
    }

    mapping(address => UserProfile) public userProfile;
    mapping(address => mapping(address => bool)) /* from */ /* to */
        public feedbackAllowed;

    function getUserProfile(address account) public view returns (UserProfile memory) {
        return userProfile[account];
    }

    function setFeedbackAllowed(address a, address b) external onlyDefxContracts {
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

    function incrementAccountStat(address account, bool isFailed) external onlyDefxContracts {
        _setFirstDeal(account);
        if (isFailed) {
            userProfile[account].failedDeals++;
        } else {
            userProfile[account].completedDeals++;
        }
    }

    function incrementCompletedDeal(address a, address b) external onlyDefxContracts {
        _incrementCompletedDeal(a);
        _incrementCompletedDeal(b);
    }

    function incrementFailedDeal(address a, address b) external onlyDefxContracts {
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
        require(feedbackAllowed[msg.sender][to], "DefxFactory: FORBIDDEN");
        _submitFeedback(msg.sender, to, isPositive, desc);
    }

    function submitFeedbackFrom(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) external onlyDefxContracts {
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
pragma solidity ^0.8.17;

// --------- TYPES & CONSTANTS -------

uint256 constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

struct Message {
    string data;
    bool isFromBuyer;
}

struct Deal {
    uint256 amountCrypto;
    uint256 collateral;
    uint256 amountFiat;
    bool isBuyerOwner;
    string paymentMethod;
    Message[] messages;
    bool fiatSent;
    uint256 startAtBlock;
    uint256 disputeFromBlock;
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
    string messageData;
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
    function getPair(address tokenA, string memory fiatCode) external view returns (address pair);

    function createPair(address tokenA, string memory fiatCode) external returns (address pair);

    function encKeys(address account) external view returns (string memory);

    function isPair(address pairAddr) external view returns (bool);

    function getIsPairOrDispute(address addr) external view returns (bool);

    function statAddress() external view returns (address);

    function disputeContract() external view returns (address);

    function setAllowedCoin(address coinAddress) external;
}

interface IDefxPair {
    function initialize(address, string memory) external;

    function closeDispute(address buyer, address seller) external;

    function cryptoAddress() external view returns (address);

    function getDeal(address buyer, address seller) external view returns (Deal memory);
}

interface IDefxStat {
    function getUserProfile(address account) external view returns (UserProfile memory);

    function setFeedbackAllowed(address a, address b) external;

    function incrementAccountStat(address account, bool isFailed) external;

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