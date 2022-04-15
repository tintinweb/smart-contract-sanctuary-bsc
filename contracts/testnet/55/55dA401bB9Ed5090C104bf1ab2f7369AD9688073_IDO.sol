// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "./interfaces/IIDO.sol";
import "./interfaces/IStaking.sol";
import "./libraries/SafeERC20.sol";

/*
    *   Most of the functions are to be called by the deployer/operator of the IDO only!
    *   init function will be called by admin contract only and that too will happen only once!
    *   To participate in sale, need to stake is not neccessary CFLU token/s to purchase sale token/s!
        but one can apply for being allowlisted.
    *   In this IDO LP, we dont have Tiers but a continous curve formula (1:N), 
        the allocation per participant is proportional 
        to 1/N (pvtN or pubN) CFLUs (set by owner of IDO project) 
        ie for each CFLU staked one will get N xyz Sale Token/s allocations
    *   to get valid and significant value of tokenPrice, lpHardcap should be > totalSupply  
    *   Notes:
        * Functionality not written for handling leftover tokens
        * Vesting of saletokens not inplemented yet! (incl. claim of tokens as well)
 */

// A token sale contract that accepts only desired USD stable coins as a payment. Blocks any direct ETH deposits.
contract IDO is IIDO {
    string private constant ZERO_ERR = "zero address";

    using SafeERC20 for IERC20;

    address public _msigWallet;
    address payable public _adminContract;
    bool public _fundsWithdrawn;
    bool public _idoCompleted;

    Timing public _timing;
    Limit public _limit;

    Address public _address;
    IdoProject public _idoProject;

    // constructor
    constructor(address msig_) { // we can pass deployer as msig for testing
        _msigWallet = msig_;
        // caller is deployer and which is admin contract
        _adminContract = payable(msg.sender);
    }

    // ------------------------- Impure Functions --------------------------------

    // creates a token sale contract that accepts only BUSD stable coin
    function init(
        Address memory address_,
        Timing memory timing_,
        Limit memory limit_,
        bool pubSaleEnabled_
    ) external paramsAreValid(address_, timing_, limit_, pubSaleEnabled_) {
        require(msg.sender == _adminContract, "caller must be admin contract");     
        require(!_idoProject.initialized, "initialized already"); 
        _idoProject.initialized = true;
        _address = address_;    // set addresses
        _timing = timing_;      // set timings
        _limit = limit_;        // set limits
        _idoProject.lpHardcap = _limit.hardcap + ((_limit.hardcap * _limit.lpShare) / 10000);
        // tokenPrice can be zero or neglegible, iff lpHardcap << totalSupply
        _idoProject.pvtTokenPrice = this.tokenPrice();
        _idoProject.pubSaleEnabled = pubSaleEnabled_;
        _idoProject.pubTokenPrice = _idoProject.pvtTokenPrice;
        emit Initialized(_msigWallet);
    }

    function forceCompleteIdo() external onlyMultisig {
        require(!_idoCompleted, "ido already completed");
        _idoCompleted = true;
    }

    // noted: as no fractions allowed so, use 100 for 1%
    function changeLPshareTo(uint16 share_100_for_1_) external initialized onlyMultisig noSaleIsGoingOn {
        require( _limit.lpShare != share_100_for_1_, "already same value!");
        // 10 -> 0.1% and 10000 -> 100%
        require(share_100_for_1_ > 10 && share_100_for_1_ < 10000, "Invalid percentage value!");
        emit LPShareChanged(_limit.lpShare, share_100_for_1_);
        _limit.lpShare = share_100_for_1_;
        _idoProject.pvtTokenPrice = this.tokenPrice();
        _idoProject.lpHardcap = _limit.totalSupply * _idoProject.pvtTokenPrice;
    }

    function enablePublicSale(bool en_) external initialized onlyMultisig {
        require(_idoProject.pubSaleEnabled != en_, "already set!");
        _idoProject.pubSaleEnabled = en_;
        emit PublicSaleEnabled(en_);
    }
    
    function setPublicTokenPrice(uint256 busdPrice_) external initialized onlyMultisig {
        _idoProject.pubTokenPrice = busdPrice_;
    }

    function setPublicSaleTimes(uint256 start_, uint256 duration_) external initialized onlyMultisig {
        require(_idoProject.pubSaleEnabled, "public sale not enabled");
        require(start_ != 0 && duration_ != 0, "must be non-zero");
        require(duration_ > start_, "invalid values");
        require(start_ > _timing.pvtStart + _timing.pvtDuration, "must be after private sale");
        _timing.pubStart = start_;
        _timing.pubDuration = duration_;
    }

    function setNewBeneficiary(address newBeneficiary_) external initialized onlyMultisig {
        require(newBeneficiary_ != address(0), ZERO_ERR);
        require(newBeneficiary_ != _address.beneficiary, "already set!");
        _address.beneficiary = newBeneficiary_;
        emit BeneficiaryChanged(newBeneficiary_);
    }

    function setNew_N_value(uint64 N_value_, bool isPrivate_) external initialized onlyMultisig {
        require(N_value_ > 0, "must be non-zero");
        require( !isPrivate_ && _idoProject.pubSaleEnabled, "pub sale not enabled!");
        if (isPrivate_) {
            require(_limit.pvtN != N_value_, "plz provide diff N"); 
            _limit.pvtN = N_value_;
        } else {
            require(_limit.pubN != N_value_, "plz provide diff N");
            _limit.pvtN = N_value_;
        }
        emit NValueChanged(N_value_, isPrivate_);
    }

    function addGiftedAllocations(address[] memory participants_, uint256[] memory allocs_) external onlyMultisig {
        uint256 count = participants_.length;
        require(allocs_.length == count, "gifted alloc count must be eq to participant count");
        for (uint256 i; i < count; i++) {
            if (_idoProject.giftAllocForParticipant[participants_[i]] == 0) {
                _idoProject.giftAllocForParticipant[participants_[i]] = allocs_[i];
            }
        }
        emit GiftAllocationDone(count, participants_, allocs_);
    }
    
    function withdrawFunds(bool allow_) external initialized onlyMultisig saleHasEnded(allow_) {
        require(!_fundsWithdrawn, "funds already withdrawn!");
        _fundsWithdrawn = true;
        uint256 lpShareAmount = _idoProject.collected - _limit.hardcap;
        // transfer final amount to beneficiary
        IERC20(_address.stableCoin).safeTransfer(_address.beneficiary, _limit.hardcap);
        // transfer lpshare amount to multisig wallet
        IERC20(_address.stableCoin).safeTransfer(_msigWallet, lpShareAmount);
        emit FundsWithdrawn(_address.beneficiary, _limit.hardcap, _msigWallet, lpShareAmount);
    }

    // we will change this logic in future, ie, we wont burn but sell! 
    function burnLeftoverTokens(bool allow_) external saleHasEnded(allow_) onlyMultisig {
        require(_idoProject.collected == _idoProject.lpHardcap, "LP-Hardcap not reached!");
        uint256 tokensLeft = IERC20(_address.saleToken).safeBalanceOf(address(this));
        require(tokensLeft > 0, "no leftover tokens to burn!");
        IERC20(_address.saleToken).safeBurn(tokensLeft);
    }

    // any1 can call this function, provided, conditions are met!
    // ip: amount of BUSD tokens
    function purchaseTokens(uint256 amount_) external initialized saleIsOngoing {
        require(amount_ > 0, "Amount is 0");
        uint256 capped = this.cappedBUSD(amount_, msg.sender); // in busd w dec
        // this fails when either already exceed max alloc or neither staked nor aloowlisted
        require(capped > 0, "no tokens possible for you!");
        
        if (this.lpHardcapXceedsWith(capped)) {
            _idoCompleted = true;
            capped = this.yetToBeRaised();
        }
        require(IERC20(_address.stableCoin).allowance(msg.sender, address(this)) >= capped, "BUSD allowance low");
        _idoProject.balances[msg.sender] += capped;
        _idoProject.collected += capped;
        // transfer busd from sender to this contract
        // so approval is must
        IERC20(_address.stableCoin).safeTransferFrom(msg.sender, capped);
        if (!_idoProject.participants[msg.sender]) {
            _idoProject.participants[msg.sender] = true;
            _idoProject.participantCount += 1;
        }
        emit Purchased(msg.sender, capped);
    }
    
    // ------------------------- all view functions ------------------------------

    // assumed the busd amount is passed with decimals
    function cappedBUSD(uint256 newBusd_, address participant_) external view returns (uint256) {
        uint256 allocation = this.finalBUSDAllocationFor(participant_); // in busd w dec
        uint256 prvBusd = this.previousBusdSpentBy(participant_); // in busd w dec
        // now cap given busd amount, if already purchased some!
        if (prvBusd + newBusd_ > allocation) {
            newBusd_ = allocation - prvBusd;
        }
        return newBusd_; // with decimals!
    }

    // returns final allocation possible for a participant in busd
    function finalBUSDAllocationFor(address participant_) external view returns (uint256) {
        // if no sale is going N will be of Pvt still
        uint256 n = this.isPublicSale() ? _limit.pubN : _limit.pvtN;
        // get cflu staked, if any?
        uint256 alloc = IStaking(_address.stakingContract).amountStakedBy(participant_); // w dec
        // convert staked cflu to busd eqv
        // 1 cflu = n tokens, 1 token = tokenprice (busd)
        // alloc # of cflu = alloc # of n tokens = alloc x n x tokenprice (in busd)
        alloc = n * alloc * this.tokenPrice();
        uint256 gAlloc = this.giftAllocationFor(participant_); // in busd w dec
        if(alloc == 0) {
            // get gifted allocation, if any, for the participant
            alloc = gAlloc;
        } else if(gAlloc > alloc) {
            alloc = gAlloc;
        }
        uint256 maxAlloc = this.maxAllocation(); // in busd w dec
        
        // first cap stakedEqv busd, if needed!
        if (alloc > maxAlloc) {
            alloc = maxAlloc;
        }

        return alloc;
    }


    function _now() external view returns (uint256) { return block.timestamp; }

    function softcap() external view returns(uint256) { return _limit.softcap; }

    function hardcap() external view returns(uint256) { return _limit.hardcap; }
    
    function lpHardcap() external view returns(uint256) { return _idoProject.lpHardcap; }
    
    function raisedTillNow() external view returns(uint256) { return _idoProject.collected; }

    function maxAllocation() external view returns (uint256) { return _limit.maxAllocation; }

    function participantCount() external view returns (uint256) { return _idoProject.participantCount; }

    function isLive() external view returns (bool) { return !_idoCompleted && (this.isPrivateSale() || this.isPublicSale()); }

    function pvtStartTime() external view returns (uint256) { return _timing.pvtStart; }
    
    function pvtEndTime() external view returns (uint256) { return _timing.pvtStart + _timing.pvtDuration; }

    function pubStartTime() external view returns (uint256) { return _timing.pubStart; }

    function pubEndTime() external view returns (uint256) { return _timing.pubStart + _timing.pubDuration; }
    
    function tokenPrice() external view returns (uint256) { return _idoProject.lpHardcap / _limit.totalSupply; }

    function yetToBeRaised() external view returns (uint256) { return _idoProject.lpHardcap - _idoProject.collected; }

    function busdDecimals() external view returns (uint256) { return IERC20(_address.stableCoin).safeDecimals(); }
    
    function previousBusdSpentBy(address participant_) external view returns (uint256) { return _idoProject.balances[participant_]; }

    function giftAllocationFor(address participant_) external view returns(uint256) { return _idoProject.giftAllocForParticipant[participant_]; }

    function lpHardcapXceedsWith(uint256 amount_) external view returns (bool) { return amount_ + _idoProject.collected > _idoProject.lpHardcap; }

    function stokenBalanceOf(address participant_) external view returns (uint256) { return this.previousBusdSpentBy(participant_) / this.tokenPrice(); }

    function isPrivateSale() external view returns(bool) { return this._now() > _timing.pvtStart && this._now() < (_timing.pvtStart + _timing.pvtDuration); }

    function isPublicSale() external view returns(bool) { return _idoProject.pubSaleEnabled && (this._now() > _timing.pubStart && this._now() < _timing.pubStart + _timing.pubDuration); }

    // ----------------------------- Modifiers -------------------------------
    modifier saleIsOngoing() {
        require(this.isLive(), "no sale is active!");
        require(!_idoCompleted, "hardcap reached hence ido completed");
        _;
    }

    modifier noSaleIsGoingOn() {
        require(!this.isLive(), "Sale is active already!");
        require(_idoCompleted, "hardcap not reached");
        _;
    }

    // notice: PLZ _review this modifier once again
    modifier saleHasEnded(bool allow_) {
        require(!this.isLive(), "sale is live");
        require(_idoCompleted || allow_, "ido not completed yet");
        _;
    }

    modifier initialized() {
        require(_idoProject.initialized, "tokensale not initialized!");
        _;
    }

    modifier onlyMultisig() {
        require(msg.sender == _msigWallet, "must be deployer of the IDO");
        _;
    }

    modifier nonZero(address a_) {
        require(a_ != address(a_), "address must be non zero");
        _;
    }

    modifier paramsAreValid(Address memory a_, Timing memory t_, Limit memory l_, bool pEn_) {
        uint256 nw = this._now();
        require(a_.owner != address(0), ZERO_ERR);
        require(a_.saleToken != address(0), ZERO_ERR);
        require(a_.stableCoin != address(0), ZERO_ERR);
        require(a_.beneficiary != address(0), ZERO_ERR);
        require(a_.stakingContract != address(0), ZERO_ERR);
        require(l_.hardcap > 0, "hardcap cant be 0");
        require(l_.totalSupply > 0, "total supply cant be 0");
        require(l_.maxAllocation > 0, "max allocation per user cant be 0!");
        require(l_.pvtN > 0 && l_.pvtN <= l_.totalSupply, "invalid pvt sale Factor!");
        require(t_.pvtDuration > 0, "Pvt Duration is 0");
        require(t_.pvtStart + t_.pvtDuration > nw, "Pvt Final time is before current time");
        if (pEn_) {
            require(l_.pubN != 0 && l_.pubN <= l_.totalSupply, "invalid pub sale Factor!");
            require(t_.pubDuration != 0, "Pub Duration is 0");
            require(t_.pubStart + t_.pubDuration > nw, "Pub end time is before current time");
            require(t_.pubStart > t_.pvtStart + t_.pvtDuration, "Pub start time is before pvt end time");
        }
        // 10 -> 0.1% and 10000 -> 100%
        require(l_.lpShare > 10 && l_.lpShare < 10000, "Invalid lpShare value!");
        _;
    }
    // -------------------------- Events ------------------------------------------
    event PublicSaleEnabled(bool);
    event Initialized(address indexed);
    event LPShareChanged(uint256, uint256);
    event Purchased(address indexed, uint256);
    event BeneficiaryChanged(address indexed);
    event NValueChanged(uint256, bool);
    event FundsWithdrawn(address indexed, uint256, address indexed, uint256);
    event GiftAllocationDone(uint256, address[] indexed, uint256[]);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function burn(uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    // EIP 2612
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IIDO {
    struct Address {
        address owner;
        address saleToken;
        address stableCoin;
        address beneficiary;
        address stakingContract;
    }

    struct Timing {
        uint256 pubStart;
        uint256 pvtStart;
        uint256 pubDuration;
        uint256 pvtDuration;
    }

    // IDO limits
    struct Limit {
        uint256 pvtN; // # of sale tokens per CFLU in pvt sale
        uint256 pubN; // # of sale tokens per CFLU in pub sale
        uint256 hardcap; // amount of BUSD to to be raised at the most
        uint256 softcap; // amount of BUSD to be raised at the least (if say we couldn't sell all the tokens----means low demand for the tokens!), in order to say IDO is success and the project needs this much at least!
        uint256 totalSupply; // total sale tokens available for sale
        uint256 maxAllocation; // to prevent single sided loading i.e single participant shouldn't get most of the tokens!
        uint16 lpShare; // part of IDO funds raised which goto admin contract. use 2000 for 20% eg
    }

    struct IdoProject {
        bool initialized; // initialized?
        bool pubSaleEnabled; // is pub sale enabled?
        uint256 lpHardcap; // hardcap including lpshare amount
        uint256 collected; // total BUSD collected
        uint256 pubTokenPrice; // will be calc when pvt sale ends and if there are any tokens left
        uint256 pvtTokenPrice; // hardcap / totalSupply
        uint256 participantCount; // keep track of # of participants
        mapping(address => bool) participants; // participants in the ido project (stakers + participants with gifted allocations)
        mapping(address => uint256) balances; // account balance in BUSD
        mapping(address => uint256) giftAllocForParticipant; // allocation for non-staking participants --- controlled by admin 
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IStaking {
    function unstake(uint256) external;

    function stake(uint256) external;

    function setIdoEndTime(address, uint32) external;

    function amountStakedBy(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

library SafeERC20 {
    function safeBalanceOf(IERC20 token, address of_)
        internal
        view
        returns (uint256)
    {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x70a08231, of_)
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeSymbol(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x95d89b41)
        );
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x06fdde03)
        );
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x313ce567)
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeBurn(IERC20 token, uint256 amount_) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x42966c68, amount_)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: Transfer failed"
        );
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0xa9059cbb, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: Transfer failed"
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        uint256 amount
    ) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x23b872dd, from, address(this), amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: TransferFrom failed"
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x23b872dd, from, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: TransferFrom failed"
        );
    }
}