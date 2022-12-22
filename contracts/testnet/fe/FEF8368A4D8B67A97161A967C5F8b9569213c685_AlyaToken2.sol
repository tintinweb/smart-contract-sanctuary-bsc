// ALYATTES.IO 2022 ©
// SPDX-License-Identifier: MIT
// WE DO NOT SAVE MONEY, WE SAVE PEOPLE.

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/// @dev Reflection tokens have 2 units of measurement: internal and external units.
/// Internal units is what’s actually stored in the contract, but they are never exposed.
/// balanceOf returns external units, transfer accepts external units as input, but the
/// internal balances mapping stores internal units.
/// The rate of conversion between internal and external units is called the reflection rate.
/// The reflection rate changes constantly as tokens are burned.
/// To convert internal units to external units: ET = IT * (externalSupply / internalSupply)
/// To convert external units to internal units: IT = ET * (internalSupply / externalSupply)
/// Internal units may be referred in the contract as “reflection” or “reflected” units, with the "r" prefix.
/// External units may be referred in the contract as “token” or “tokenized” units, with the "t" prefix.

contract AlyaToken2 is Context, IBEP20, Ownable {
    event AccountExcluded(address indexed);
    event AccountIncluded(address indexed);

    /// @dev Account balances
    mapping(address => uint256) private _rOwned;

    /// @dev Balances of excluded accounts
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    /// @dev Returns whether an account has been excluded from the ecosystem.
    /// Accounts excluded from the ecosystem are not subject to fees. (e.g. charity account, exchanges, etc.)
    mapping(address => bool) public isExcluded;

    string private _NAME;
    string private _SYMBOL;
    uint256 private immutable _DECIMALS;
    address public AlyaCare;

    uint256 private constant _MAX = ~uint256(0);
    uint256 private immutable _DECIMALFACTOR;

    uint256 private _tTotal;
    uint256 private _rTotal;

    uint256 private _tFeeTotal;
    uint256 private _tCharityTotal;

    uint256 public _TAX_FEE;
    uint256 public _BURN_FEE;
    uint256 public _CHARITY_FEE;

    uint256 public maximumTarget;
    uint256 public immutable nRewarMod;
    uint256 public immutable nWtime;
    uint256 public lastBlock;
    uint256 public immutable genesisReward;

    /// @dev Tokenized supply of token held by excluded accounts.
    uint256 public tExcludedSupply;

    /// @dev Reflected supply of token held by excluded accounts.
    uint256 public rExcludedSupply;

    uint256 public constant arrayLimit = 115;

    /// @dev Latest lucky block where a "Proof-of-Activity" sign has taken place.
    uint256 public latestLuckyEthBlock;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint256 _supply,
        uint256 _txFee,
        uint256 _burnFee,
        uint256 _charityFee,
        address _AlyaCare,
        address tokenOwner
    ) {
        _NAME = _name;
        _SYMBOL = _symbol;
        _DECIMALS = _decimals;
        _DECIMALFACTOR = 10 ** _DECIMALS;
        _tTotal = _supply * _DECIMALFACTOR + 1;
        _rTotal = _MAX - (_MAX % _tTotal);
        _TAX_FEE = _txFee;
        _BURN_FEE = _burnFee;
        _CHARITY_FEE = _charityFee;
        maximumTarget = 0;
        nRewarMod = 29743;
        nWtime = 7776000;
        lastBlock = 0;
        genesisReward = 1;
        AlyaCare = _AlyaCare;
        _owner = tokenOwner;
        _rOwned[address(1)] = (1 * _rTotal) / _tTotal;
        _rOwned[tokenOwner] = _rTotal - _rOwned[address(1)];
        emit Transfer(address(0), tokenOwner, _tTotal);
        emit Transfer(tokenOwner, address(1), 1);

        if (_AlyaCare != address(0)) _excludeAccount(_AlyaCare);
        _excludeAccount(address(this));
        _excludeAccount(address(0));
        _excludeAccount(tokenOwner);
    }

    function name() external view returns (string memory) {
        return _NAME;
    }

    function symbol() external view returns (string memory) {
        return _SYMBOL;
    }

    function decimals() external view returns (uint8) {
        return uint8(_DECIMALS);
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    /// @dev Return the current supply of token in the ecosystem.
    function getCurrentSupply() external view returns (uint256, uint256) {
        return (_rTotal - rExcludedSupply, _tTotal - tExcludedSupply);
    }

    /// @dev Return the balance of account in internal units.
    function balanceOfInternal(address account) external view returns (uint256) {
        return _rOwned[account];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(recipient != address(0), 'TOKEN20: transfer to the zero address');
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 allowance_ = _allowances[sender][_msgSender()];
        require(allowance_ >= amount, 'TOKEN20: transfer amount exceeds allowance');
        _approve(sender, _msgSender(), allowance_ - amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        uint256 allowance_ = _allowances[_msgSender()][spender];
        require(allowance_ >= subtractedValue, 'TOKEN20: decreased allowance below zero');
        _approve(_msgSender(), spender, allowance_ - subtractedValue);
        return true;
    }

    /// @dev Returns the total amount of fees collected.
    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    /// @dev Returns the total amount of tokens burned, both voluntarily and as transfer fees.
    function totalBurn() external view returns (uint256) {
        return _tOwned[address(0)];
    }

    /// @dev Returns the total amount of tokens donated to charity.
    function totalCharity() external view returns (uint256) {
        return _tCharityTotal;
    }

    /// @dev Distribute tAmount tokens to all holders, including yourself.
    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(!isExcluded[sender], 'Excluded addresses cannot call this function');
        uint256 rAmount = tAmount *
            ((_rTotal - rExcludedSupply) / (_tTotal - tExcludedSupply));
        _rOwned[sender] -= rAmount;
        _rTotal -= rAmount;
        _tFeeTotal += tAmount;
        emit Transfer(sender, address(0), tAmount);
    }

    /// @dev Converts external units to internal units.
    function reflectionFromToken(uint256 tAmount) public view returns (uint256 rAmount) {
        (uint256 rSupply, uint256 tSupply) = (
            _rTotal - rExcludedSupply,
            _tTotal - tExcludedSupply
        );
        return tAmount * (rSupply / tSupply);
    }

    /// @dev Converts internal units to external units.
    function tokenFromReflection(uint256 rAmount) public view returns (uint256 tAmount) {
        (uint256 rSupply, uint256 tSupply) = (
            _rTotal - rExcludedSupply,
            _tTotal - tExcludedSupply
        );
        return rAmount / (rSupply / tSupply);
    }

    /// @dev Excludes an account from the ecosystem, making it immune to fees.
    function _excludeAccount(address account) internal {
        uint256 rOwnedUser = _rOwned[account];
        uint256 tOwnedUser = tokenFromReflection(rOwnedUser);

        _tOwned[account] = tOwnedUser;
        isExcluded[account] = true;
        rExcludedSupply += rOwnedUser;
        tExcludedSupply += tOwnedUser;

        emit AccountExcluded(account);
    }

    /// @dev Includes an account in the ecosystem, making it subject to fees.
    function _includeAccount(address account) internal {
        uint256 tOwnedUser = _tOwned[account];
        uint256 rOwnedUser = reflectionFromToken(tOwnedUser);

        rExcludedSupply -= rOwnedUser;
        tExcludedSupply -= tOwnedUser;

        _rOwned[account] = rOwnedUser;
        _tOwned[account] = 0;
        isExcluded[account] = false;

        emit AccountIncluded(account);
    }

    function excludeAccount(address account) external onlyOwner {
        require(!isExcluded[account], 'Account is already excluded');
        require(account != address(1), 'Cannot exclude address(1)');
        _excludeAccount(account);
    }

    function includeAccount(address account) external onlyOwner {
        require(account != address(this), 'Cannot include the contract');
        require(account != address(0), 'Cannot include the zero address');
        require(account != AlyaCare, 'Cannot include the AlyaCare address');
        require(isExcluded[account], 'Account is already included');
        _includeAccount(account);
    }

    function setAsCharityAccount(address account) external onlyOwner {
        require(account != address(0), 'zero address');
        if (AlyaCare != address(0)) _includeAccount(AlyaCare);
        _excludeAccount(account);
        AlyaCare = account;
    }

    function updateFee(
        uint256 _txFee,
        uint256 _burnFee,
        uint256 _charityFee
    ) external onlyOwner {
        require(_txFee <= 5 && _burnFee <= 5 && _charityFee <= 5, 'Fee must be <= 5%');
        _TAX_FEE = _txFee;
        _BURN_FEE = _burnFee;
        _CHARITY_FEE = _charityFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), 'TOKEN20: approve from the zero address');
        require(spender != address(0), 'TOKEN20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 tAmount) external {
        require(tAmount > 0, 'Burn amount must be greater than zero');
        address sender = _msgSender();
        _transfer(sender, address(0), tAmount);
    }

    function _transfer(address sender, address recipient, uint256 tAmount) private {
        require(sender != address(0), 'TOKEN20: transfer from the zero address');
        require(sender != address(1), 'TOKEN20: transfer from address(1)');
        require(tAmount > 0, 'Transfer amount must be greater than zero');
        require(tAmount <= balanceOf(sender), 'Transfer amount exceeds balance');

        (uint256 rSupply, uint256 tSupply) = (
            _rTotal - rExcludedSupply,
            _tTotal - tExcludedSupply
        );
        bool isExcludedSender = isExcluded[sender];
        bool isExcludedRecipient = isExcluded[recipient];

        if (isExcludedSender && isExcludedRecipient) {
            _tOwned[sender] -= tAmount;
            _tOwned[recipient] += tAmount;

            emit Transfer(sender, recipient, tAmount);
        } else if (!isExcludedSender && isExcludedRecipient) {
            _rOwned[sender] -= tAmount * (rSupply / tSupply);
            _tOwned[recipient] += tAmount;

            rExcludedSupply += tAmount * (rSupply / tSupply);
            tExcludedSupply += tAmount;

            emit Transfer(sender, recipient, tAmount);
        } else {
            // The standard transfer happens in 4 steps:
            // 1) transfer the entire specified amount to the recipient
            // 2) burn the appropriate amount of token, updating supply counters accordingly
            // 3) distribute the appropriate amount of token, updating balances accordingly
            //    the sender's balance remains the same - tokens are distributed among everyone else
            // 4) transfer the appropriate amount to the charity wallet

            // Step 1: transfer
            if (isExcludedSender && !isExcludedRecipient) {
                _tOwned[sender] -= tAmount;
                _rOwned[recipient] += tAmount * (rSupply / tSupply);

                rExcludedSupply -= tAmount * (rSupply / tSupply);
                tExcludedSupply -= tAmount;

                (rSupply, tSupply) = (
                    _rTotal - rExcludedSupply,
                    _tTotal - tExcludedSupply
                );
            } else {
                uint256 rTransferAmount = tAmount * (rSupply / tSupply);
                _rOwned[sender] -= rTransferAmount;
                _rOwned[recipient] += rTransferAmount;
            }

            // Step 2: burn
            uint256 tBurnAmount = (tAmount * _BURN_FEE) / 100;
            {
                _rTotal -= tBurnAmount * (rSupply / tSupply);
                _rOwned[recipient] -= tBurnAmount * (rSupply / tSupply);
                _tTotal -= tBurnAmount;
                emit Transfer(sender, address(0), tBurnAmount);
            }

            // Step 3: redistribute tax
            uint256 tDistributeAmount = (tAmount * _TAX_FEE) / 100;
            {
                (rSupply, tSupply) = (
                    _rTotal - rExcludedSupply,
                    _tTotal - tExcludedSupply
                );
                uint256 rDistributeAmount = tDistributeAmount * (rSupply / tSupply);
                _rTotal -= rDistributeAmount;
                _rOwned[recipient] -= rDistributeAmount;
            }

            // Step 4: transfer to charity
            uint256 tCharityAmount = (tAmount * _CHARITY_FEE) / 100;
            if (AlyaCare != address(0)) {
                (rSupply, tSupply) = (
                    _rTotal - rExcludedSupply,
                    _tTotal - tExcludedSupply
                );
                uint256 rCharityAmount = tCharityAmount * (rSupply / tSupply);
                _tOwned[AlyaCare] += tCharityAmount;
                _rOwned[recipient] -= rCharityAmount;
                rExcludedSupply += rCharityAmount;
                tExcludedSupply += tCharityAmount;
                emit Transfer(sender, AlyaCare, tCharityAmount);
            } else tCharityAmount = 0;

            emit Transfer(
                sender,
                recipient,
                tAmount - tBurnAmount - tDistributeAmount - tCharityAmount
            );

            // update fancy totals
            _tFeeTotal += tDistributeAmount;
            _tOwned[address(0)] += tBurnAmount;
            _tCharityTotal += tCharityAmount;
        }
    }

    struct stakeInfo {
        uint256 _stocktime;
        uint256 _stockamount;
    }

    address[] totalminers;

    mapping(address => stakeInfo) nStockDetails;

    struct rewarddetails {
        uint256 _artyr;
        bool _didGetReward;
        bool _didisign;
    }

    mapping(string => rewarddetails) nRewardDetails;

    struct nBlockDetails {
        uint256 _bTime;
        uint256 _tInvest;
    }

    mapping(uint256 => nBlockDetails) bBlockIteration;

    struct activeMiners {
        address bUser;
    }

    mapping(uint256 => activeMiners[]) aMiners;

    function uintToString(uint256 v) internal pure returns (string memory str) {
        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint256 j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function totalMinerCount() external view returns (uint256) {
        return totalminers.length;
    }

    function addressHashs() public view returns (uint256) {
        return uint256(uint160(msg.sender)) % 10000000000;
    }

    function append(
        string memory a,
        string memory b
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(a, '-', b));
    }

    function generalCheckPoint() private view returns (string memory) {
        return append(uintToString(addressHashs()), uintToString(lastBlock));
    }

    function stakerStatus(address _addr) public view returns (bool) {
        if (nStockDetails[_addr]._stocktime == 0) {
            return false;
        } else {
            return true;
        }
    }

    function stakerAmount(address _addr) external view returns (uint256) {
        if (nStockDetails[_addr]._stocktime == 0) {
            return 0;
        } else {
            return nStockDetails[_addr]._stockamount;
        }
    }

    function stakerTimeStart(address _addr) external view returns (uint256) {
        return nStockDetails[_addr]._stocktime;
    }

    function stakerActiveTotal() external view returns (uint256) {
        return aMiners[lastBlock].length;
    }

    function getContractAddress() external view returns (address) {
        return address(this);
    }

    /// @dev Start "mining" (staking) tokens.
    /// @param mineamount The amount of tokens to be staked.
    function startMining(uint256 mineamount) external returns (uint256) {
        uint256 realMineAmount = mineamount * _DECIMALFACTOR;
        require(balanceOf(msg.sender) >= realMineAmount, 'not enough token');
        require(realMineAmount >= 500 * _DECIMALFACTOR);
        require(nStockDetails[msg.sender]._stocktime == 0);
        nStockDetails[msg.sender]._stocktime = block.timestamp;
        nStockDetails[msg.sender]._stockamount = realMineAmount;
        maximumTarget += mineamount;
        totalminers.push(msg.sender);

        if (!isExcluded[msg.sender]) _excludeAccount(msg.sender);

        _transfer(msg.sender, address(this), realMineAmount);
        return 200;
    }

    /// @dev Stop mining and get your stake back.
    function tokenPayBack() external returns (uint256) {
        require(stakerStatus(msg.sender));
        require(nStockDetails[msg.sender]._stocktime + nWtime < block.timestamp);
        nStockDetails[msg.sender]._stocktime = 0;
        maximumTarget -= uint256(nStockDetails[msg.sender]._stockamount) / _DECIMALFACTOR;
        _transfer(
            address(this),
            msg.sender,
            uint256(nStockDetails[msg.sender]._stockamount)
        );
        if (isExcluded[msg.sender]) _includeAccount(msg.sender);
        return nStockDetails[msg.sender]._stockamount;
    }

    /// @dev Do a "Proof-of-Activity" sign at a specified recent block.
    /// @param _bnumber The block when the sign is done.
    function necessarySignForReward(uint256 _bnumber) external returns (uint256) {
        require(stakerStatus(msg.sender));
        require((block.number - 1) - _bnumber <= 150);
        require(nStockDetails[msg.sender]._stocktime + nWtime > block.timestamp);
        require(latestLuckyEthBlock == _bnumber || latestLuckyEthBlock + 3600 < _bnumber);
        require(uint256(blockhash(_bnumber)) % nRewarMod == 1);
        latestLuckyEthBlock = _bnumber;

        if (bBlockIteration[lastBlock]._bTime + 1800 < block.timestamp) {
            lastBlock += 1;
            bBlockIteration[lastBlock]._bTime = block.timestamp;
        }
        require(nRewardDetails[generalCheckPoint()]._artyr == 0);

        bBlockIteration[lastBlock]._tInvest += nStockDetails[msg.sender]._stockamount;
        nRewardDetails[generalCheckPoint()]._artyr = block.timestamp;
        nRewardDetails[generalCheckPoint()]._didGetReward = false;
        nRewardDetails[generalCheckPoint()]._didisign = true;
        aMiners[lastBlock].push(activeMiners(msg.sender));
        return 200;
    }

    /// @dev Get the reward for "mining" a block.
    /// @param _bnumber The block to get the reward for.
    function rewardGet(uint256 _bnumber) external returns (uint256) {
        require(stakerStatus(msg.sender));
        require((block.number - 1) - _bnumber > 150);
        require(uint256(blockhash(_bnumber)) % nRewarMod == 1);
        require(nStockDetails[msg.sender]._stocktime + nWtime > block.timestamp);
        require(!nRewardDetails[generalCheckPoint()]._didGetReward);
        require(nRewardDetails[generalCheckPoint()]._didisign);

        uint256 halving = lastBlock / 300;
        uint256 totalRA = 58000 * _DECIMALFACTOR;
        if (halving == 0) {
            totalRA = 58000 * _DECIMALFACTOR;
        } else if (halving == 1) {
            totalRA = 81000 * _DECIMALFACTOR;
        } else if (halving == 2) {
            totalRA = 98000 * _DECIMALFACTOR;
        } else if (halving == 3) {
            totalRA = 109000 * _DECIMALFACTOR;
        } else if (halving == 4) {
            totalRA = 100000 * _DECIMALFACTOR;
        } else {
            totalRA = 0;
        }

        uint256 usersReward = ((totalRA *
            (nStockDetails[msg.sender]._stockamount * 100)) /
            bBlockIteration[lastBlock]._tInvest) / 100;
        nRewardDetails[generalCheckPoint()]._didGetReward = true;

        _transfer(address(this), msg.sender, usersReward);
        return usersReward;
    }

    struct memoInfo {
        uint256 _receiveTime;
        uint256 _receiveAmount;
        address _senderAddr;
        string _senderMemo;
    }

    mapping(address => memoInfo[]) memoGetProcess;

    function sendMemoToken(
        uint256 _amount,
        address _to,
        string memory _memo
    ) external returns (uint256) {
        memoGetProcess[_to].push(memoInfo(block.timestamp, _amount, msg.sender, _memo));
        _transfer(msg.sender, _to, _amount);
        return 200;
    }

    function sendMemoOnly(address _to, string memory _memo) external returns (uint256) {
        memoGetProcess[_to].push(memoInfo(block.timestamp, 0, msg.sender, _memo));
        _transfer(msg.sender, _to, 0);
        return 200;
    }

    function yourMemos(
        address _addr,
        uint256 _index
    ) external view returns (uint256, uint256, string memory, address) {
        uint256 rTime = memoGetProcess[_addr][_index]._receiveTime;
        uint256 rAmount = memoGetProcess[_addr][_index]._receiveAmount;
        string memory sMemo = memoGetProcess[_addr][_index]._senderMemo;
        address sAddr = memoGetProcess[_addr][_index]._senderAddr;
        if (memoGetProcess[_addr][_index]._receiveTime == 0) {
            return (0, 0, '0', _addr);
        } else {
            return (rTime, rAmount, sMemo, sAddr);
        }
    }

    function yourMemosCount(address _addr) external view returns (uint256) {
        return memoGetProcess[_addr].length;
    }

    function appendMemos(
        string memory a,
        string memory b,
        string memory c,
        string memory d
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(a, '#', b, '#', c, '#', d));
    }

    function addressToString(address _addr) public pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = '0123456789abcdef';

        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(value[i + 12] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function getYourMemosOnly(address _addr) external view returns (string[] memory) {
        uint256 total = memoGetProcess[_addr].length;
        string[] memory messages = new string[](total);

        for (uint256 i = 0; i < total; i++) {
            messages[i] = appendMemos(
                uintToString(memoGetProcess[_addr][i]._receiveTime),
                memoGetProcess[_addr][i]._senderMemo,
                uintToString(memoGetProcess[_addr][i]._receiveAmount),
                addressToString(memoGetProcess[_addr][i]._senderAddr)
            );
        }

        return messages;
    }

    /// @dev Batch transfer.
    function alyaMultiSend(
        address[] memory _receivers,
        uint256[] memory _amounts
    ) external {
        require(
            _receivers.length <= arrayLimit,
            'Array length should not exceed limit 115'
        );
        require(
            _receivers.length == _amounts.length,
            'Addresses must equal amounts size.'
        );

        for (uint256 i = 0; i < _receivers.length; i++) {
            _transfer(_msgSender(), _receivers[i], _amounts[i]);
        }
    }
}