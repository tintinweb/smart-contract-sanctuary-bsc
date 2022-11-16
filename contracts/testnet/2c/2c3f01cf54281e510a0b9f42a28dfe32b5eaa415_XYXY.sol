/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
            if (returndata.length > 0) {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}



contract XYXY is Context, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address constant feeWallet = 0x889b75c1A1e3E29565b1971BfE52bA3b25804044;
    IERC20 public BUSD;
    bool bStart;

    struct User {
        uint256 totalDeposits;
        uint256 totalWithdrawn;
        uint256 totalWithdrawable;
        uint256 lastClaim;
        uint256 maxPayout;
        uint256 claimCount;
        uint256 refBonus;
        uint256 totalRefBonus;
    }

    mapping(address => User) public Users;

    event Deposit(address indexed addr, uint256 value);
    event Compound(address indexed addr, uint256 value);
    event Claim(address indexed addr, uint256 value);
    event Withdraw(address indexed addr, uint256 value);
    event Referred(address indexed user, address referral, uint256 value);

    constructor() {
        BUSD = IERC20(0x690afF4a3A0d346332b8b3edDF6034Fe48C2caDb);
    }

    function deposit(uint256 amtx, address referrer) public noReentrant {
        require(bStart, "Not started yet.");

        uint256 userDeposit = (amtx * 90) / 100;
        uint256 fee = (amtx * 10) / 100;

        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        BUSD.safeTransfer(feeWallet, fee);
        
        User storage user = Users[msg.sender];
        User storage refUser = Users[referrer];

        user.totalDeposits += userDeposit;
        user.maxPayout += userDeposit * 4;

        user.lastClaim = block.timestamp;

        emit Deposit(msg.sender, amtx);

        uint256 refAmtx = amtx * 10 / 100;

        if (referrer == msg.sender) {
            referrer = address(0);
        }

        refUser.refBonus += refAmtx;
        refUser.totalRefBonus += refAmtx;

        emit Referred(msg.sender, referrer, amtx);
    }

    function compound() public noReentrant {
        User storage user = Users[msg.sender];
        uint256 compoundAmt = user.totalWithdrawable;

        user.totalDeposits += compoundAmt;
        user.totalWithdrawable = 0;

        emit Compound(msg.sender, compoundAmt);
    }

    function claim() public noReentrant {
        User storage user = Users[msg.sender];
        uint256 rn = block.timestamp;
        uint256 rewards = user.totalDeposits * 25 / 1000;

        require(
            user.maxPayout - user.totalWithdrawn > 0,
            "You cannot claim anymore if your max payout has been reached."
        );

        require(rn - user.lastClaim >= 86400, "You can only claim once per day."); 

        user.totalWithdrawable += rewards;

        user.claimCount += 1;

        user.lastClaim = rn;

        emit Claim(msg.sender, rewards);
    }

    function withdraw() public noReentrant {
        User storage user = Users[msg.sender];

        uint256 transferAmt = user.totalWithdrawable;

        uint256 feePercent = 30;

        if (user.claimCount >= 30) {
            feePercent = 0;
        } else if (user.claimCount >= 25) {
            feePercent = 5;
        } else if (user.claimCount >= 20) {
            feePercent = 10;
        } else if (user.claimCount >= 15) {
            feePercent = 15;
        } else if (user.claimCount >= 10) {
            feePercent = 20;
        } else if (user.claimCount >= 5) {
            feePercent = 25;
        }
        if (transferAmt + user.totalWithdrawn > user.maxPayout) {
            uint256 rawPay = user.maxPayout - user.totalWithdrawn;
            uint256 rWithdrawable = (rawPay * feePercent) / 100;
            user.totalWithdrawable = 0;
            user.totalDeposits = 0;
            user.totalWithdrawn = user.maxPayout;
            user.claimCount = 0;
            BUSD.safeTransfer(msg.sender, rWithdrawable);

            emit Withdraw(msg.sender, rWithdrawable);
        } else {
            uint256 rWithdrawable = (transferAmt * feePercent) / 100; // 10% is left in contract, that's withdraw fee for tvl
            user.totalWithdrawable = 0;
            user.totalWithdrawn += transferAmt;
            user.claimCount = 0;

            BUSD.safeTransfer(msg.sender, rWithdrawable);

            emit Withdraw(msg.sender, transferAmt);
        }
    }

    function withdrawRef() public noReentrant {
        User storage user = Users[msg.sender];

        require(
            user.refBonus > 0,
            "You don't have any referrals to claim!"
        );

        uint256 transferAmt = user.refBonus;
        user.refBonus = 0;

        BUSD.safeTransfer(msg.sender, transferAmt);
    }

    function start() public onlyOwner {
        require(bStart == false, "Started already");
        bStart = true;
    }

    function getDepositAmount(address addr)
        public
        view
        returns (uint256 totDeps)
    {
        User storage user = Users[addr];
        return user.totalDeposits;
    }

    function getClaimedTime(address addr)
        public
        view
        returns (uint256 lasCla)
    {
        User storage user = Users[addr];
        return user.lastClaim;
    }

    function getClaimedAmount(address addr)
        public
        view
        returns (uint256 totClaims)
    {
        User storage user = Users[addr];
        return user.totalWithdrawable;
    }

    function getWithdrawInfo(address addr)
        public
        view
        returns (uint256 totwd)
    {
        User storage user = Users[addr];
        return user.totalWithdrawn;
    }

    function getMaxInfo(address addr)
        public
        view
        returns (uint256 totmax)
    {
        User storage user = Users[addr];
        return user.maxPayout;
    }

    function getTotalRefBonus(address addr)
        public
        view
        returns (uint256 totref)
    {
        User storage user = Users[addr];
        return user.refBonus;
    }

    function getRefWithdrawn(address addr)
        public
        view
        returns (uint256 totref)
    {
        User storage user = Users[addr];
        return user.totalRefBonus - user.refBonus;
    }

}