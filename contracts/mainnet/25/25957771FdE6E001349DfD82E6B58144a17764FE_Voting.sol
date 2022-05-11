/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface ITokenomicsToken is IERC20, IERC20Metadata {
    function feeDenominator() external view returns (uint16);

    function maxSellBuyFee() external view returns (uint8);

    function sellBuyBurnFee() external view returns (uint8);

    function sellBuyCharityFee() external view returns (uint8);

    function sellBuyOperatingFee() external view returns (uint8);

    function sellBuyMarketingFee() external view returns (uint8);

    function sellBuyTotalFee() external view returns (uint8);

    function setSellBuyFee(
        uint8 sellBuyCharityFee_,
        uint8 sellBuyOperatingFee_,
        uint8 sellBuyMarketingFee_
    ) external;

    function maxTransferFee() external view returns (uint8);

    function transferBurnFee() external view returns (uint8);

    function transferCharityFee() external view returns (uint8);

    function transferOperatingFee() external view returns (uint8);

    function transferMarketingFee() external view returns (uint8);

    function transferTotalFee() external view returns (uint8);

    function setTransferFee(
        uint8 transferCharityFee_,
        uint8 transferOperatingFee_,
        uint8 transferMarketingFee_
    ) external;

    function process() external;

    function isFeeExempt(address account) external view returns (bool);

    function setFeeExempt(address account, bool exempt) external;

    function strategy() external view returns (ITokenomicsStrategy strategy_);

    function setStrategy(ITokenomicsStrategy strategy_) external;

    function dexPair() external view returns (address);

    function setDexPair(address dexPair_) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    event FeePayment(address indexed payer, uint256 fee);

    event Burnt(address indexed account, uint256 amount);
}


interface IFCKToken is ITokenomicsToken {
    function teamAndAdvisorsCap() external view returns (uint256);

    function marketingReserveCap() external view returns (uint256);

    function platformReserveCap() external view returns (uint256);

    function launchedAt() external view returns (uint256);

    function launched() external view returns (bool);

    function launch() external returns (bool);

    function mint(address account, uint256 amount) external;

    function pause() external;

    function unpause() external;

    function maxTxAmount() external view returns (uint256);

    function setMaxTxAmount(uint256 maxTxAmount_) external;

    function maxWalletBalance() external view returns (uint256);

    function setMaxWalletBalance(uint256 maxWalletBalance_) external;

    function isTxLimitExempt(address account) external view returns (bool);

    function setIsTxLimitExempt(address recipient, bool exempt) external;

    event Minted(address indexed account, uint256 amount);

    event Launched(uint256 launchedAt);

    event FeePayment(address indexed sender, uint256 balance, uint256 fee);
}

interface ITokenomicsStrategy {
    function process() external;
}

interface IVoting {
    function createProposal(
        address recipient,
        uint256 amount,
        uint256 endsAt
    ) external;

    function voteFor() external;

    function voteAgainst() external;

    function canTransfer(address sender) external view returns (bool);

    function complete() external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Voting is IVoting, Ownable {
    event ProposalCreated(
        uint256 id,
        address indexed creator,
        address indexed recipient,
        uint256 amount
    );
    event ProposalCompleted(
        uint256 id,
        address indexed creator,
        address indexed recipient,
        uint256 amount,
        bool success
    );

    struct Proposal {
        uint256 id;
        address creator;
        address recipient;
        uint256 amount;
        bool active;
        mapping(uint256 => mapping(address => uint256)) voters;
        uint256 votersCount;
        uint256 tokensFor;
        uint256 tokensAgainst;
        uint256 createdAt;
        uint256 endsAt;
    }

    IFCKToken private _token;

    Proposal public proposal;

    constructor(IFCKToken token_) {
        _token = token_;
    }

    function createProposal(
        address recipient,
        uint256 amount,
        uint256 endsAt
    ) external override onlyOwner {
        require(
            !proposal.active,
            "Voting: Active proposal should be completed"
        );
        require(
            endsAt > block.timestamp + 23 * 1 hours,
            "Voting: Should be active more than 23 hours"
        );
        require(
            _token.allowance(msg.sender, address(this)) >= amount,
            "Voting: Insufficient funds"
        );
        require(recipient != address(0), "Voting: Wrong recipient address");
        proposal.id += 1;
        proposal.creator = msg.sender;
        proposal.recipient = recipient;
        proposal.amount = amount;
        proposal.active = true;
        proposal.createdAt = block.timestamp;
        proposal.endsAt = endsAt;
        proposal.tokensFor = 0;
        proposal.tokensAgainst = 0;
        proposal.votersCount = 0;
        emit ProposalCreated(
            proposal.id,
            proposal.creator,
            proposal.recipient,
            proposal.amount
        );
    }

    function voteFor() external override {
        _vote(msg.sender, true);
    }

    function voteAgainst() external override {
        _vote(msg.sender, false);
    }

    function canTransfer(address sender) external view override returns (bool) {
        return
            !proposal.active ||
            (proposal.active && proposal.voters[proposal.id][sender] == 0);
    }

    function complete() external override onlyOwner {
        require(
            proposal.active && proposal.endsAt <= block.timestamp,
            "Voting: There is no active proposal"
        );
        proposal.active = false;
        bool success = proposal.tokensFor > proposal.tokensAgainst;
        if (success) {
            _token.transferFrom(
                proposal.creator,
                proposal.recipient,
                proposal.amount
            );
        }
        emit ProposalCompleted(
            proposal.id,
            proposal.creator,
            proposal.recipient,
            proposal.amount,
            success
        );
    }

    function _vote(address account_, bool for_) internal {
        require(_token.balanceOf(msg.sender) > 0, "Voting: Insufficient funds");
        require(
            proposal.endsAt >= block.timestamp,
            "Voting: There is no active proposal"
        );
        require(
            proposal.voters[proposal.id][account_] == 0,
            "Voting: This address has already voted"
        );
        proposal.votersCount += 1;
        proposal.voters[proposal.id][account_] = 1;
        uint256 amount = _token.balanceOf(account_);
        if (for_) {
            proposal.tokensFor += amount;
        } else {
            proposal.tokensAgainst += amount;
        }
    }
}