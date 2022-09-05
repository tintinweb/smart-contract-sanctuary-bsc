/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// 🅣🅔🅐🅜 🅑🅛🅧🅝 🅟🅡🅔🅢🅔🅝🅣🅢
// ▒█▀▀█ ▒█░░░ ▀▄▒▄▀ ▒█▄░▒█ 　 ▒█▀▀█ ▒█░▒█ ▒█▀▀▀█ ▒█▀▀▄ 　 ▒█▀▀█ ▒█▀▀▀█ ▒█▀▀█ ▒█░▄▀ ▒█▀▀▀ ▀▀█▀▀ 
// ▒█▀▀▄ ▒█░░░ ░▒█░░ ▒█▒█▒█ 　 ▒█▀▀▄ ▒█░▒█ ░▀▀▀▄▄ ▒█░▒█ 　 ▒█▄▄▀ ▒█░░▒█ ▒█░░░ ▒█▀▄░ ▒█▀▀▀ ░▒█░░ 
// ▒█▄▄█ ▒█▄▄█ ▄▀▒▀▄ ▒█░░▀█ 　 ▒█▄▄█ ░▀▄▄▀ ▒█▄▄▄█ ▒█▄▄▀ 　 ▒█░▒█ ▒█▄▄▄█ ▒█▄▄█ ▒█░▒█ ▒█▄▄▄ ░▒█░░

pragma solidity ^0.8.13;


// █░░ █ █▄▄ █▀█ ▄▀█ █▀█ █ █▀▀ █▀
// █▄▄ █ █▄█ █▀▄ █▀█ █▀▄ █ ██▄ ▄█
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

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
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
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// █▀▀ █▀█ █▄░█ ▀█▀ █▀█ ▄▀█ █▀▀ ▀█▀
// █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▀█ █▄▄ ░█░
struct User {
    uint256 totalDeps;
    uint256 totalWithdrawn;
    uint256 totalWithdrawable;
    uint256 lastClaim;
    uint256 lastWithdraw;
    uint256 maxPayout;
    uint256 claimCount;
    uint256 totalRefClaimable;
}

contract BLXNBusdRocket is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant devWallet = 0x052E9FB338F18170edA1F69fDC546183e1e4474E;
    address constant ideaWallet = 0x857Bf8867a41441653134500D6c6457Ee3cc1934;
    address constant fundingWallet = 0x64b7A3CD189a886438243F0337b64f7ddf1B18D3;
    mapping(address => User) public Users;
    mapping(address => uint256) public Whitelist;
    IERC20 public BUSD;
    event Deposit(address indexed walletAddress, uint256 value);
    event Claim(address indexed walletAddress, uint256 value);
    event Withdraw(address indexed walletAddress, uint256 value);
    event WithdrawHlf(address indexed walletAddress, uint256 value);
    event Referred(address indexed user, address referral, uint256 value);
    event NotReferred(address indexed user, uint256 value);

    constructor() {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    function MakeDeposit(uint256 amtx, address reffy) public noReentrant {
        User storage user = Users[msg.sender];
        User storage refUser = Users[reffy];
        uint256 firstlaunchTime = 1662393600; 
        uint256 secondlaunchTime = 1662480000; 
        uint256 nowTime = block.timestamp;

        require(
            secondlaunchTime < nowTime || Whitelist[msg.sender] == 1,
            "General launch or VIP required."
        );
        // First, we check to see if general launch has started OR if you're on the VIP whitelist.

        require(firstlaunchTime < nowTime, "VIP launch hasn't started yet.");
        // Then, we check to see if VIP launch has started.

        require(reffy != msg.sender, "You cannot refer yourself.");
        // This checks to make sure the referral address being used isn't your own.

        uint256 userDeposit = (amtx * 950) / 1000;
        // This sets your deposit amount to be 95% of what you put in - to account for 5% deposit fee.

        uint256 devFee = (amtx * 20) / 1000;
        // 2% of your deposit amount goes to the dev team.

        uint256 fundingFee = (amtx * 30) / 1000;
        // 3% of your deposit amount goes to repay our loan for funding Team BLXN based on our seed funding agreement.

        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        BUSD.safeTransfer(devWallet, devFee);
        BUSD.safeTransfer(fundingWallet, fundingFee);
        // Once we've set all the right amounts, we can actually make the transfers.

        user.totalDeps += userDeposit;
        // Add your deposit amount to your total deposits.

        user.maxPayout += userDeposit * 4;
        // Set your max payout to be 4x your deposit.

        user.lastClaim = block.timestamp;
        // Set your last claim time to now so we can have our timer for 1 day start.

        user.lastWithdraw = block.timestamp;
        // Set your last withdraw time to now so we can have our timer for 1 week start.

        emit Deposit(msg.sender, amtx);

        uint256 refAmtx = userDeposit.mul(30).div(1000);
        // 3% of your deposit amount is the referral bonus.
        if (
            reffy == 0x000000000000000000000000000000000000dEaD ||
            reffy == msg.sender
        ) {
            // If you have no referral, this is the address used for referrals.

            refUser.totalRefClaimable += 0;
            user.totalRefClaimable += 0;
            // No referrals are added for anyone in this case.
            emit NotReferred(msg.sender, amtx);
        } else {
            // If you used a referral:

            refUser.totalRefClaimable += refAmtx;
            user.totalRefClaimable += refAmtx;
            // Make the referral bonus available to both you and the person who referred you.
            emit Referred(msg.sender, reffy, amtx);
        }
    }

    function MakeClaim() public noReentrant {
        User storage user = Users[msg.sender];
        uint256 rn = block.timestamp;
        uint256 userDeps;

        if (user.claimCount <= 5) {
            userDeps = user.totalDeps * 100;
            // If you've claimed 5 times or less, your daily is 10%
        }
        if (user.claimCount > 5) {
            userDeps = user.totalDeps * 120;
            // If you've claimed more than 5 times, your daily is 12%
        }
        if (user.claimCount > 10) {
            userDeps = user.totalDeps * 140;
            // If you've claimed more than 5 times, your daily is 14%
        }
        if (user.claimCount > 15) {
            userDeps = user.totalDeps * 160;
            // If you've claimed more than 5 times, your daily is 16%
        }
        if (user.claimCount > 20) {
            userDeps = user.totalDeps * 180;
            // If you've claimed more than 5 times, your daily is 18%
        }

        uint256 userDeps2 = userDeps / 1000;

        require(
            user.maxPayout - user.totalWithdrawn > 0,
            "You cannot claim anymore if your max payout has been reached."
        );
        // In order to claim, you must not have reached your max payout.

        require(rn - user.lastClaim >= 86400, "You can only claim once per day."); 
        // In order to claim, 1 day must have passed since the last claim.

        user.totalWithdrawable += userDeps2;
        // Add your claim amount to your withdrawable amount.

        user.claimCount += 1;

        user.lastClaim = rn;
        // Update your last claim time to be right now.

        emit Claim(msg.sender, userDeps2);
        // Send an event for tracking purposes.
    }

    function MakeWithdraw() public noReentrant {
        User storage user = Users[msg.sender];

        uint256 rn = block.timestamp;

        require(
            rn - user.lastWithdraw > 345600,
            "You can only withdraw once per 4 days."
        ); 
        // Make sure at least 4 days have passed before you can withdraw.

        uint256 transferAmt = user.totalWithdrawable / 2;
        // The amount you're going to receive is half of what is available to withdraw.

        if (transferAmt + user.totalWithdrawn > user.maxPayout) {
            // If the amount is higher than your max payout:

            uint256 rawPay = user.maxPayout - user.totalWithdrawn;
            // You will only receive the remaining amunt between what you've withdrawn and your max.

            uint256 devFee = (rawPay * 30) / 1000;
            // Withdraw fee 3% goes to dev team.

            uint256 ideaFee = (rawPay * 10) / 1000;
            // Withdraw fee 1% goes to DinoBUSD founders.

            uint256 fundingFee = (rawPay * 10) / 1000;
            // Withdraw fee 1% goes to our seed round funding investors.
            // Total 5% in withdraw fees.

            uint256 userNet = rawPay - devFee - ideaFee - fundingFee;
            // Your net withdrawal is the amount you should receive, minus fees.

            user.totalWithdrawable = 0;
            // Your withdrawable amount is now 0.

            user.totalDeps = 0;
            // Your total deposits are now set to 0 because you have reached max payout.

            user.totalWithdrawn = user.maxPayout;
            // Your total withdrawn will now be displayed as your max payout.

            user.lastWithdraw = block.timestamp;
            // Your last withdrawal time is set to now.

            user.claimCount = 0;
            // Your claim count is reset to 0.

            if (Whitelist[msg.sender] == 1) {
                userNet = (userNet * 1050) / 1000;
            }
            // If you're a whitelisted user, you get 5% more.

            BUSD.safeTransfer(msg.sender, userNet);
            BUSD.safeTransfer(devWallet, devFee);
            BUSD.safeTransfer(ideaWallet, ideaFee);
            BUSD.safeTransfer(fundingWallet, fundingFee);
            // Once we've set all the right values, we can transfer all the amounts.

            emit Withdraw(msg.sender, rawPay);
        } else {
            // If the amount you're withdrawing is less than max payout:
            uint256 devFee = (transferAmt * 30) / 1000;
            // Withdraw fee 3% goes to dev team.
            uint256 ideaFee = (transferAmt * 10) / 1000;
            // Withdraw fee 1% goes to DinoBUSD founders.
            uint256 fundingFee = (transferAmt * 10) / 1000;
            // Withdraw fee 1% goes to our seed round funding investors.
            // Total 5% in withdraw fees.

            uint256 userNet = transferAmt - devFee - ideaFee - fundingFee;
            // Your net withdrawal is the amount you should receive, minus fees.

            user.totalWithdrawable = 0;
            // Your withdrawable amount is set to 0 again.

            user.totalDeps += transferAmt;
            // Your total deposits have now increased by 50% of your withdrawable amount.

            user.totalWithdrawn += transferAmt;
            // Your total withdrawn will now increase by 50% of your withdrawable amount.

            user.lastWithdraw = block.timestamp;
            // Your last withdrawal time is set to now.

            user.claimCount = 0;
            // Your claim count is reset to 0.

            if (Whitelist[msg.sender] == 1) {
                userNet = (userNet * 1050) / 1000;
            }

            BUSD.safeTransfer(msg.sender, userNet);
            BUSD.safeTransfer(devWallet, devFee);
            BUSD.safeTransfer(ideaWallet, ideaFee);
            BUSD.safeTransfer(fundingWallet, fundingFee);
            // Once we've set all the right values, we can transfer all the amounts.

            emit Withdraw(msg.sender, transferAmt);
        }
    }

    function MakeRefWithdraw() public noReentrant {
        User storage user = Users[msg.sender];

        require(
            user.totalRefClaimable > 0,
            "You don't have any referrals to claim!"
        );
        // We check to make sure you actually have something to withdraw.

        uint256 transferAmt = user.totalRefClaimable;
        // We assign a name to the amount you can withdraw.

        user.totalRefClaimable = 0;
        // We set your referral balance to 0.

        BUSD.safeTransfer(msg.sender, transferAmt);
        // We send you the referral amount you have available.
    }

    function whiteListSignup() public payable noReentrant {
        uint256 nowTime = block.timestamp;
        require(nowTime < 1662393600, "VIP reservation period has ended."); 
        // We check to make sure the VIP reservation period has not closed yet.

        require(Whitelist[msg.sender] == 0, "You're already VIP!");
        // We make sure you can only reserve VIP once.
        

        require(
            msg.value == 0.05 ether,
            "VIP reservation price is set at 0.05 BNB."
        );
        // We make sure only 0.05BNB can be used for VIP reservations.

        payable(devWallet).transfer(msg.value);
        // We send the reservation amount to the dev team.

        Whitelist[msg.sender] = 1;
        // We add your address to the whitelist.
    }

    function getdepInfo(address walletAddress)
        public
        view
        returns (uint256 totDeps)
    {
        User storage user = Users[walletAddress];
        return user.totalDeps;
    }

    function getClaimInfo(address walletAddress)
        public
        view
        returns (uint256 lasCla)
    {
        User storage user = Users[walletAddress];
        return user.lastClaim;
    }

    function getLastWithdrawInfo(address walletAddress)
        public
        view
        returns (uint256 lasWit)
    {
        User storage user = Users[walletAddress];
        return user.lastWithdraw;
    }

    function getclaimInfo(address walletAddress)
        public
        view
        returns (uint256 totClaims)
    {
        User storage user = Users[walletAddress];
        return user.totalWithdrawable;
    }

    function getWithdrawInfo(address walletAddress)
        public
        view
        returns (uint256 totwd)
    {
        User storage user = Users[walletAddress];
        return user.totalWithdrawn;
    }

    function getMaxInfo(address walletAddress)
        public
        view
        returns (uint256 totmax)
    {
        User storage user = Users[walletAddress];
        return user.maxPayout;
    }

    function getRefTotal(address walletAddress)
        public
        view
        returns (uint256 totref)
    {
        User storage user = Users[walletAddress];
        return user.totalRefClaimable;
    }

    function getReffTotal(address walletAddress)
        public
        view
        returns (uint256 totref)
    {
        User storage user = Users[walletAddress];
        return user.totalRefClaimable;
    }

    function getVIPUser(address walletAddress)
        public
        view
        returns (bool trueFalse)
    {
        if (Whitelist[walletAddress] > 0) {
            return true;
        } else {
            return false;
        }
    }

    function addVIPuser(address vip) public {
        require(msg.sender == devWallet, "Only devs can add to the VIP whitelist");
        require (block.timestamp < 1662393600, "You cannot add to the VIP list after VIP launch.");

        Whitelist[vip] = 1;

    }


}