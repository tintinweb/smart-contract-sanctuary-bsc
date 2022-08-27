/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

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
}
//libraries

struct User {
    uint256 totalDeps;
    uint256 totalWithdrawn;
    uint256 totalClaimable;
    uint256 lastClaim;
    uint256 lastWithdraw;
    uint256 maxPayout;
    uint256 txCount;
    uint256 totalRefClaimable;
}

contract BLXNBusdRocket {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public devFee = 40;
    uint256 public ideaFee = 10;
    uint256 public refFee = 30;
    uint256 public dailyEarn = 200;
    uint256 public percentDivider = 1000;

    address constant devWallet = 0x32926D702C8Af9Bcf59435921a233e3D3DBc3fD5;
    address constant ideaWallet = 0x32926D702C8Af9Bcf59435921a233e3D3DBc3fD5;

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
        BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    }

    function MakeDeposit(uint256 amtx, address reffy) public {
        User storage user = Users[msg.sender];
        User storage refUser = Users[reffy];
        uint256 firstlaunchTime = 1659759118; //changeTime LM
        uint256 secondlaunchTime = 1659759118; //changeTime LM
        uint256 nowTime = block.timestamp;

        require(secondlaunchTime < nowTime || Whitelist[msg.sender] == 1);
        require(firstlaunchTime < nowTime);
        require(reffy != msg.sender);

        uint256 amtz = (amtx * 950) / 1000;
        uint256 amty = (amtx * 40) / 1000;
        uint256 amtp = (amtx * 10) / 1000;

        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        BUSD.safeTransfer(devWallet, amty);
        BUSD.safeTransfer(ideaWallet, amtp);

        user.totalDeps += amtz;
        user.maxPayout += amtz * 5;
        user.txCount += 1;
        user.lastClaim = block.timestamp;
        user.lastWithdraw = block.timestamp;

        emit Deposit(msg.sender, amtx);

        uint256 refAmtx = amtz.mul(30).div(1000);
        if (
            reffy == 0x000000000000000000000000000000000000dEaD ||
            reffy == msg.sender
        ) {
            refUser.totalRefClaimable += 0;
            user.totalRefClaimable += 0;
            emit NotReferred(msg.sender, amtx);
        } else {
            refUser.totalRefClaimable += refAmtx;
            user.totalRefClaimable += refAmtx;
            emit Referred(msg.sender, reffy, amtx);
        }
    }

    function MakeClaim() public {
        User storage user = Users[msg.sender];
        uint256 rn = block.timestamp;
        uint256 userDeps = user.totalDeps * 200;
        uint256 userDeps2 = userDeps / 1000;

        require(user.maxPayout - user.totalWithdrawn > 0);
        require(rn - user.lastClaim >= 0); //change to 86400 LM

        user.totalClaimable += userDeps2;
        user.lastClaim = rn;
        emit Claim(msg.sender, userDeps2);
    }

    function MakeWithdraw() public {
        User storage user = Users[msg.sender];

        uint256 rn = block.timestamp;
        require(rn - user.lastWithdraw > 0); //change to 604800 LM
        uint256 transferAmt = user.totalClaimable / 2;

        if (transferAmt + user.totalWithdrawn > user.maxPayout) {
            uint256 rawPay = user.maxPayout - user.totalWithdrawn;
            user.totalClaimable = 0;
            user.totalDeps = 0;
            user.totalWithdrawn = user.maxPayout;
            user.lastWithdraw = block.timestamp;
            BUSD.safeTransfer(msg.sender, rawPay);
            emit Withdraw(msg.sender, rawPay);
        } else {
            user.totalClaimable = 0;
            user.totalDeps += transferAmt;
            user.totalWithdrawn += transferAmt;
            user.lastWithdraw = block.timestamp;
            BUSD.safeTransfer(msg.sender, transferAmt);
            emit Withdraw(msg.sender, transferAmt);
        }
    }

    function MakeRefWithdraw() public {
        User storage user = Users[msg.sender];

        require(user.totalRefClaimable > 0);

        uint256 transferAmt = user.totalRefClaimable;
        user.totalRefClaimable = 0;

        BUSD.safeTransfer(msg.sender, transferAmt);
    }

    function whiteListSignup() public {
        uint256 nowTime = block.timestamp;
        require(nowTime < 0); //change time to whitelist launch time LM
        payable(devWallet).transfer(0.05 ether);
        Whitelist[msg.sender] = 1;
    }
}