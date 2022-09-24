/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

pragma solidity ^0.8.13;

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
        require(isContract(target), "Address: call to non-contract"); //discuss this line
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

struct User {
    uint256 startDate;
    uint256 divs;
    uint256 refBonus;
    uint256 totalInits;
    uint256 totalWiths;
    uint256 totalAccrued;
    uint256 lastWith;
    uint256 timesCmpd;
    uint256 keyCounter;
    uint256 userMax;
    Depo[] depoList;
}
struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amt;
    address reffy;
    bool initialWithdrawn;
}
struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
    uint256 compounds;
}
struct DivPercs {
    uint256 daysInSeconds;
    uint256 divsPercentage;
}
struct FeesPercs {
    uint256 daysInSeconds;
    uint256 feePercentage;
}

struct WL {
    bool member;
}

contract BLXNBusdHike is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 constant firstlaunch = 1664600400; //fixed to October 1st, 2022
    uint256 constant secondlaunch = 1664686800; //fixed to October 2nd, 2022
    uint256 constant percentdiv = 1000;
    uint256 refPercentage = 30;
    uint256 devPercentage = 50;
    uint256 wmPercentage = 50;
    mapping(address => User) public UsersKey;
    mapping(uint256 => FeesPercs) public FeesKey;
    mapping(uint256 => Main) public MainKey;
    mapping(address => WL) public WhiteList;
    IERC20 public BUSD;
    address devOwner;
    address ideaOwner;

    constructor() {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        devOwner = 0x052E9FB338F18170edA1F69fDC546183e1e4474E;
        ideaOwner = 0x64b7A3CD189a886438243F0337b64f7ddf1B18D3;
    }

    // Function to create stakes on stablecoins, takes in the parameters of amount deposited and referral.
    function BLXNStake(uint256 amtx, address ref) public payable noReentrant {
        // Makes sure you can't deposit early/before launch date, unless you are a VIP/Whitelist member.
        require(
            block.timestamp >= firstlaunch ||
                WhiteList[msg.sender].member == true,
            "You are not part of whitelist"
        );

        // Requires all users to deposit only after the app's official launch date of October 2nd, 2022.
        require(block.timestamp >= secondlaunch, "App did not launch yet.");

        // Makes sure people can not refer themeselves.
        require(ref != msg.sender, "You cannot refer yourself!");

        // Transfers funds from wallet to current contract
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);

        // Gives us access to manipulate individual data structures
        User storage user = UsersKey[msg.sender];
        User storage user2 = UsersKey[ref];
        Main storage main = MainKey[1];

        // If deposit is first deposit ever, it sets the last withdrawal to now so dividends can be calculated correctly.
        if (user.lastWith == 0) {
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        // Sets deposit amount to be 90% of the real amount because of the fees taken.
        uint256 userStakePercentAdjustment = 900;
        uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(
            percentdiv
        );
        uint256 stakeFee = amtx.mul(devPercentage).div(percentdiv);

        // Sets the max for withdrawals
        user.userMax += adjustedAmt * 3;

        // Adds the deposit to total deposits
        user.totalInits += adjustedAmt;

        // Calculate the referral amount
        uint256 refAmtx = adjustedAmt.mul(refPercentage).div(percentdiv);

        // If user has no references, nobody will make a referral fee
        if (ref == 0x000000000000000000000000000000000000dEaD) {
            user2.refBonus += 0;
            user.refBonus += 0;

            // If user has references, add the referral amounts to the Referrer & Referee
        } else {
            user2.refBonus += refAmtx;
            user.refBonus += refAmtx;
        }

        // Adds deposit struct to each wallet's struct to update data after deposit was made.
        user.depoList.push(
            Depo({
                key: user.depoList.length,
                depoTime: block.timestamp,
                amt: adjustedAmt,
                reffy: ref,
                initialWithdrawn: false
            })
        );

        // Adds 1 to the count of user deposits.
        user.keyCounter += 1;

        // Adds 1 to overall contract deposits to keep track for UI purposes.
        main.ovrTotalDeps += 1;

        // Adds 1 to overall users to keep track for UI for UI purposes.
        main.users += 1;

        // Transfers fees to Dev Wallet
        BUSD.safeTransfer(devOwner, stakeFee);
    }

    // Function to display user information on deposits for UI purposes.
    function BLXNUserInfo() external view returns (Depo[] memory depoList) {
        User storage user = UsersKey[msg.sender];

        // Returns user deposit info for UI purposes.
        return (user.depoList);
    }

    // Function to withdraw the earned dividends since the last withdrawal, returns the raw withdrawal amount
    function BLXNCollect() public noReentrant returns (uint256 withdrawAmount) {
        // Sets variables to wallet struct to give us access to manipulate the data based on wallet interaction
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        WL storage wl = WhiteList[msg.sender];

        // Makes sure wallets are not withdrawing more than the User Max of 3x of their deposit.
        require(user.userMax > user.totalWiths);

        // Stores value of wallet's dividends earned.
        uint256 x = BLXNCalculateEarnings(msg.sender);

        // Updates each deposit's time to now so next dividends are based on new date.
        for (uint256 i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].initialWithdrawn == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        // If withdrawal amount makes user max out on dividends, it'll withdraw the difference between User Max & User's Total Withdrawals
        if (x + user.totalWiths > user.userMax) {
            x = user.userMax - user.totalWiths;
            user.totalWiths = user.totalWiths + x;
            for (uint256 i = 0; i < user.depoList.length; i++) {
                if (user.depoList[i].initialWithdrawn == false) {
                    user.depoList[i].initialWithdrawn = true;
                }
            }
        }

        // Sets a variable to 5% of user's withdrawal amount so it can be paid to idea project.
        uint256 ideaTransfer = x.mul(50).div(1000);

        // Resets the dividends variable to reflect 95% if User is part of Whitelist(remaining after fees).
        if (wl.member == true) {
            x = x.mul(950).div(1000);
        }

        // Resets the dividends variable to reflect 90%(remaining after fees).
        if (wl.member == false) {
            x = x.mul(900).div(1000);
        }

        // User struct gets updated with new values as well as Main struct for UI purposes.
        main.ovrTotalWiths += x;
        user.totalWiths += x;

        // Sets the last withdrawal time to now.
        user.lastWith = block.timestamp;

        // Transfer amounts to User & Idea Wallet.
        BUSD.safeTransfer(msg.sender, x);
        BUSD.safeTransfer(ideaOwner, ideaTransfer);

        // Returns actual withdrawal amount.
        return x;
    }

    // Function to withdraw the referral amounts earned for the user
    function BLXNTakeRef() public {
        // Sets variable to User's struct for easy reference
        User storage user = UsersKey[msg.sender];

        // Takes value in for referral totals and resets it to 0
        uint256 amtz = user.refBonus;
        user.refBonus = 0;

        // Transfers refferal total amount to user
        BUSD.safeTransfer(msg.sender, amtz);
    }

    // Function to stake the refferal amounts(instead of withdrawing it) and creates + deposits a new stake.
    function BLXNStakeRef() public {
        // Sets variables to user's structs & main struct(for UI purposes)
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        // Requires the user has at least 10BUSD in referral amounts earned.
        require(user.refBonus > 10);

        // Sets the variable to the amount accumulated through referrals.
        uint256 refferalAmount = user.refBonus;

        // Resets the user's struct to have 0 referral fees.
        user.refBonus = 0;

        // Sets all referral stakes to have no second referrals(for deposit purposes)
        address ref = 0x000000000000000000000000000000000000dEaD;

        // Creates a new deposit struct and add's it to user's struct.

        user.depoList.push(
            Depo({
                key: user.keyCounter,
                depoTime: block.timestamp,
                amt: refferalAmount,
                reffy: ref,
                initialWithdrawn: false
            })
        );

        // Updates the user's max amount that they can withdraw by adding the referral stake amount x3.
        user.userMax += refferalAmount * 3;

        // Updates keycounter to keep a record of how many deposits.
        user.keyCounter += 1;

        // Updates main struct's overall deposit quantity(for UI purposes)
        main.ovrTotalDeps += 1;
    }

    // Calculates how much dividends a wallet has earned
    function BLXNCalculateEarnings(address dy)
        public
        view
        returns (uint256 totalWithdrawable)
    {
        // Sets variables to user's structs for access and data manipulation
        User storage user = UsersKey[dy];

        // Sets a vairable to 0 so it can add dividends for every deposit and return it with one variable
        uint256 with;

        // Iterate through each deposit struct in User's deposit list and calculate the dividends earned by user calculate function.
        for (uint256 i = 0; i < user.depoList.length; i++) {
            uint256 elapsedTime = block
                .timestamp
                .sub(user.depoList[i].depoTime)
                .div(86400);
            uint256 elapsedTimeb = block
                .timestamp
                .sub(user.depoList[i].depoTime)
                .mod(86400);
            uint256 amount = user.depoList[i].amt;
            uint256 t = Retro(amount, elapsedTime, 2);
            uint256 q = RetroRem(amount, elapsedTimeb, elapsedTime, 2);
            with += t;
            with += q;
        }

        // Return the sum of all dividends
        return with;
    }

    // Function to add dividends back in User's deposits so they can earn dividends on newly added deposits(from dividends).
    function BLXNCompound() public {
        // Sets variables to wallet struct to give us access to manipulate the data based on wallet interaction
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        // Stores value of wallet's dividends earned.
        uint256 y = BLXNCalculateEarnings(msg.sender);

        // Iterates through each deposits and updates the last deposit time to now
        for (uint256 i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].initialWithdrawn == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        // Adds total dividends into User's struct as new deposit.
        user.depoList.push(
            Depo({
                key: user.keyCounter,
                depoTime: block.timestamp,
                amt: y,
                reffy: 0x000000000000000000000000000000000000dEaD,
                initialWithdrawn: false
            })
        );

        // Adds one to amount of deposits by User to keep track of deposit quantity.
        user.keyCounter += 1;

        // Adds one to main struct deposits for UI purposes.
        main.ovrTotalDeps += 1;

        // Keeps track on main struct of all compounds that happen
        main.compounds += 1;

        // Updates last withdrawal time to now
        user.lastWith = block.timestamp;
    }

    // Function to join whitelist and get early access.
    function JoinVIP() public payable {
        // Sets variable to access Whitelist Struct.
        WL storage wl = WhiteList[msg.sender];

        // Requires that the current time is after the Whitelist launch date.
        require(
            block.timestamp < firstlaunch,
            "You can only join VIP before the VIP launch"
        );

        // Ensures users cannot accidentally purchase VIP more than once.
        require(wl.member == false, "You already have VIP!");

        // Requires the amount to join Whitelist is 0.05BNB.
        require(msg.value == 0.05 ether, "VIP launch price is 0.05 BNB");

        // Sends whitelist fees to dev wallet
        payable(devOwner).transfer(msg.value);

        // Sets Whitelist struct mapped to User to true so they access the dapp early.
        wl.member = true;
    }

    // Function to calculate the dividends for less than a day(remaining time beyond days). Takes in the deposit amount the dividends will be based on,
    // the hours elapsed since the last day counted, the time elapsed in days, and the increment amount for every 10 days with a max of 50 days)
    function RetroRem(
        uint256 amty,
        uint256 timea,
        uint256 timeb,
        uint256 inc
    ) public pure returns (uint256 remPayOut) {
        // sets empty variable to 0 before we set it based on the amount of days passed
        uint256 y;

        if (timeb < 10) {
            y = 1;
        }

        if (timeb > 10 && timeb < 20) {
            y = 2;
        }

        if (timeb > 20 && timeb < 30) {
            y = 3;
        }

        if (timeb > 30 && timeb < 40) {
            y = 4;
        }

        if (timeb > 40) {
            y = 5;
        }

        // sets the increment amount to new variable and then updates it to correct increment amount based on time elapsed.
        uint256 incr = inc;
        incr = incr * y;

        // calculates the amount of time passed since last full day, takes the percentage of the day elapsed, and calculates the dividends earned from it.
        uint256 rem = timea;
        uint256 remCalc = rem.mul(100).div(86400);
        uint256 payOut = remCalc.mul(incr).mul(amty).div(10000);

        // returns total payout accrued past the last full day
        return payOut;
    }

    // Function to calculate the amount of dividends earned based on how many full days have passed.
    function Retro(
        uint256 amount,
        uint256 time,
        uint256 increment
    ) public pure returns (uint256 na) {
        // sets a variable to 0 so we cankeep track of calulcated dividends
        uint256 newAmt;

        // sets variable to starting increment
        uint256 z = increment; // 1

        // Calculates dividends based on a days passed since last withdrawal
        if (time < 10) {
            newAmt += amount.mul(z).div(100) * time;
            return newAmt;
        }

        if (time >= 10) {
            uint256 remainder = time % 10;
            uint256 x = time - remainder;
            uint256 y = x / 10; // 3

            if (y > 5) {
                y = 5;
            }

            for (uint256 i = 0; i < y; i++) {
                newAmt += amount.mul(z).div(100) * 10;
                if (i < 4) {
                    z += increment;
                }
                if (i == y - 1) {
                    newAmt += amount.mul(z).mul(remainder).div(100);
                }
            }
        }

        // return the updated value of newAmt with all the summed dividends.
        return newAmt;
    }
}