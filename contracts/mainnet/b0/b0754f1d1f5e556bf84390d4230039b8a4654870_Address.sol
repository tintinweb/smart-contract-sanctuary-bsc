/**
 *Submitted for verification at BscScan.com on 2022-10-30
*/

// Sources flattened with hardhat v2.9.5 https://hardhat.org
// File @openzeppelin/contracts/token/ERC20/[email protected]
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.0;
interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity ^0.8.0;
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }
    function cap() public view virtual returns (uint256) {
        return _cap;
    }
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}

pragma solidity ^0.8.0;
abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

pragma solidity ^0.8.0;
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

pragma solidity ^0.8.0;
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity ^0.8.0;
contract MockERC20 is ERC20, Ownable {
    using SafeMath for uint256;

    constructor() ERC20("MockERC20", "MERC20") {
        _mint(_msgSender(), 1 ether);
    }
}

pragma solidity ^0.8.0;
interface IStakingPool {
    function onERC20Received(address from, uint256 amount) external;
}

pragma solidity ^0.8.0;
contract MockStakingPool is IStakingPool {
    event ERC20Received(address from, uint256 amount);

    function onERC20Received(address from, uint256 amount) external override {
        emit ERC20Received(from, amount);
    }
}

pragma solidity ^0.8.1;
library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.0;
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;
contract SpotBotVestingWallet is Context, Ownable {
    using SafeMath for uint256;

    event EtherReleased(address indexed receiver, uint256 amount);
    event ERC20Released(
        address indexed token,
        address indexed receiver,
        uint256 amount
    );

    uint256 private _released;
    bool private _isVestingStarted = false;

    mapping(address => uint256) private _erc20Released;
    address[] private _beneficiaries;
    uint64 private _start;
    uint64 private _duration;

    constructor(uint64 startTimestamp, uint64 durationSeconds) {
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    modifier onlyBeforeStart() {
        require(
            _isVestingStarted == false,
            "SpotBotVestingWallet: Vesting is already active"
        );
        _;
    }

    function setStartTimestamp(uint64 timestamp)
        external
        onlyOwner
        onlyBeforeStart
    {
        _start = timestamp;
    }

    function setDuration(uint64 value) external onlyOwner onlyBeforeStart {
        _duration = value;
    }

    function addBeneficiaries(address[] calldata addrs)
        external
        onlyOwner
        onlyBeforeStart
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            _beneficiaries.push(addrs[i]);
        }
    }

    function addBeneficiary(address addr) external onlyOwner onlyBeforeStart {
        _beneficiaries.push(addr);
    }

    function removeBeneficiary(address addr)
        external
        onlyOwner
        onlyBeforeStart
    {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            if (_beneficiaries[i] == addr) {
                _beneficiaries[i] = _beneficiaries[_beneficiaries.length - 1];
                _beneficiaries.pop();
                break;
            }
        }
    }

    receive() external payable virtual {}
    function isVestingStarted() public view virtual returns (bool) {
        return _isVestingStarted;
    }
    function beneficiaries() public view virtual returns (address[] memory) {
        return _beneficiaries;
    }
    function start() public view virtual returns (uint256) {
        return _start;
    }
    function duration() public view virtual returns (uint256) {
        return _duration;
    }
    function released() public view virtual returns (uint256) {
        return _released;
    }
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }
    function release() public virtual {
        _setVestingStarted();

        uint256 releasable = vestedAmount(uint64(block.timestamp)) - released();
        _released += releasable;

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            emit EtherReleased(
                _beneficiaries[i],
                releasable.div(_beneficiaries.length)
            );
            Address.sendValue(
                payable(_beneficiaries[i]),
                releasable.div(_beneficiaries.length)
            );
        }
    }
    function release(address token) public virtual {
        _setVestingStarted();

        uint256 releasable = vestedAmount(token, uint64(block.timestamp)) -
            released(token);
        _erc20Released[token] += releasable;

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            emit ERC20Released(
                _beneficiaries[i],
                token,
                releasable.div(_beneficiaries.length)
            );
            SafeERC20.safeTransfer(
                IERC20(token),
                _beneficiaries[i],
                releasable.div(_beneficiaries.length)
            );
        }
    }
    function vestedAmount(uint64 timestamp)
        public
        view
        virtual
        returns (uint256)
    {
        return _vestingSchedule(address(this).balance + released(), timestamp);
    }
    function vestedAmount(address token, uint64 timestamp)
        public
        view
        virtual
        returns (uint256)
    {
        return
            _vestingSchedule(
                IERC20(token).balanceOf(address(this)) + released(token),
                timestamp
            );
    }

    function _setVestingStarted() internal virtual {
        if (_isVestingStarted == false && uint64(block.timestamp) >= start()) {
            _isVestingStarted = true;
        }
    }
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp)
        internal
        view
        virtual
        returns (uint256)
    {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}

pragma solidity ^0.8.0;
abstract contract RosyWhaleToken is ERC20, ERC20Capped, ERC20Burnable, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 1 * 1 ether;
    uint256 public constant TOTAL_SUPPLY = 450000000 * 1 ether;

    address public pancakeRouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public activityPoolAddress = address(0);
    address public referralPoolAddress = address(0);
    address public stakingPoolAddress = address(0);

    bool public feesEnabled = true;
    bool public pauseEnabled = false;
    bool public stakingPoolCallbackEnabled = false;

    uint256 public minTxAmount = 0;

    constructor(address tgeWallet)
        ERC20("SpotBot", "SPBT")
        ERC20Capped(TOTAL_SUPPLY)
    {
        ERC20._mint(tgeWallet, INITIAL_SUPPLY);
        ERC20._mint(address(this), TOTAL_SUPPLY.sub(INITIAL_SUPPLY));
    }

    function setPancakeRouter(address addr) external onlyOwner {
        pancakeRouterAddress = addr;
    }
    
    function setActivityPoolAddress(address addr) external onlyOwner {
        activityPoolAddress = addr;
    }

    function setReferralPoolAddress(address addr) external onlyOwner {
        referralPoolAddress = addr;
    }

    function setStakingPoolAddress(address addr) external onlyOwner {
        stakingPoolAddress = addr;
    }

    function setMinTxAmount(uint256 amount) external onlyOwner {
        minTxAmount = amount;
    }

    function setFeesEnabled(bool value) external onlyOwner {
        feesEnabled = value;
    }

    function setPauseEnabled(bool value) external onlyOwner {
        pauseEnabled = value;
    }

    function setStakingPoolCallbackEnabled(bool value) external onlyOwner {
        stakingPoolCallbackEnabled = value;
    }

    function distributeSaleToken(
        address EarlyBirdSaleWallet,
        address SeedSaleWallet,
        address PrivateSaleWallet,
        address PublicSaleWallet
    ) external onlyOwner {
        _transfer(address(this), EarlyBirdSaleWallet, TOTAL_SUPPLY * 0.03 ether); // 3%
        _transfer(address(this), SeedSaleWallet, TOTAL_SUPPLY * 0.12 ether); // 12%
        _transfer(address(this), PrivateSaleWallet, TOTAL_SUPPLY * 0.12 ether); // 12% 
        _transfer(address(this), PublicSaleWallet, TOTAL_SUPPLY * 0.04 ether); // 4%
    }

    function distributeToken(
        address team,
        address advisors,
        address marketing,
        address liquidity,
        address operational,
        address airdrops,
        address treasury,
        address rewards
    ) external onlyOwner {
        _transfer(address(this), team, TOTAL_SUPPLY * 0.08 ether); // 8%
        _transfer(address(this), advisors, TOTAL_SUPPLY * 0.05 ether); // 5%
        _transfer(address(this), marketing, TOTAL_SUPPLY * 0.01 ether); // 1%
        _transfer(address(this), operational, TOTAL_SUPPLY * 0.1 ether); // 10%
        _transfer(address(this), airdrops, TOTAL_SUPPLY * 0.05 ether); // 5%
        _transfer(address(this), liquidity, TOTAL_SUPPLY * 0.06 ether ); // 6%
        _transfer(address(this), treasury, TOTAL_SUPPLY * 0.1 ether); // 10%
        _transfer(address(this), rewards, TOTAL_SUPPLY * 0.15 ether); // 15%

    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(
            amount >= minTxAmount,
            "SpotBot: amount is less than minTxAmount"
        );

        address sender = _msgSender();
        require(
            sender == owner() || !pauseEnabled,
            "SpotBot: transactions are paused"
        );

        uint256 tTotal = _reflectFees(sender, to, amount);

        _transfer(sender, to, tTotal);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            amount >= minTxAmount,
            "SpotBot: amount is less than minTxAmount"
        );

        require(
            from == owner() || !pauseEnabled,
            "SpotBot: transactions are paused"
        );

        address spender = _msgSender();

        _spendAllowance(from, spender, amount);

        uint256 tTotal = _reflectFees(from, to, amount);
        _transfer(from, to, tTotal);

        return true;
    }

    function _reflectFees(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 _tTotal) {
        if (!feesEnabled) {
            return amount;
        }

        if (from == owner()) {
            return amount;
        }
        uint256 tTotal = amount;
        // only apply fee if sender / receiver is not pancake router
        if (from != pancakeRouterAddress && to != pancakeRouterAddress) {
            uint256 tFeeActivityPool = 0;
            uint256 tFeeReferralPool = 0;
            uint256 tFeeStakingPool = 0;

            if (activityPoolAddress != address(0)) {
                tFeeActivityPool = tTotal.mul(75).div(10000); // 0.75%
                _transfer(from, activityPoolAddress, tFeeActivityPool);
            }

            if (referralPoolAddress != address(0)) {
                tFeeReferralPool = tTotal.mul(75).div(10000); // 0.75%
                _transfer(from, referralPoolAddress, tFeeReferralPool);
            }

            if (stakingPoolAddress != address(0)) {
                tFeeStakingPool = tTotal.mul(15).div(1000); // 1.5%
                _transfer(from, stakingPoolAddress, tFeeStakingPool);

                if (stakingPoolCallbackEnabled) {
                    IStakingPool(stakingPoolAddress).onERC20Received(
                        from,
                        tFeeStakingPool
                    );
                }
            }

            tTotal = tTotal.sub(tFeeActivityPool).sub(tFeeReferralPool).sub(
                tFeeStakingPool
            );
        }

        require(tTotal > 0, "Invalid transaction amount");

        return tTotal;
    }

    function emergencyWithdraw(address receiver) external onlyOwner {
        _transfer(address(this), receiver, balanceOf(address(this)));
    }

    function _mint(address account, uint256 amount)
        internal
        virtual
        override(ERC20, ERC20Capped)
    {
        super._mint(account, amount);
    }
}