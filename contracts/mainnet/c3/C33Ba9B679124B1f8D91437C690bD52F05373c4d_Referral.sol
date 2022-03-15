/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;

interface IBEP20 {
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


contract Context {
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account)
    internal
    pure
    returns (address payable)
    {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-call-value
        (bool success,) = recipient.call.value(amount)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IBEP20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeBEP20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeBEP20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract Referral is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    uint8 constant MAX_REFER_DEPTH = 5;

    struct Account {
        address referrer;
        uint256 referredCount;
    }

    event RegisteredReferer(address referee, address referrer);
    event PaidReferral(address from, address to, uint256 amount, uint256 level);
    event PaidReferralDirectly(
        address claimer,
        address referrer,
        uint256 amount
    );
    event Claim(address claimer, address referrer, uint256 amount);

    mapping(address => Account) public accounts;

    mapping(address => bool) public isClaimed;

    uint256[] public levelRate;
    uint256 public decimals;
    uint256 public amountAirdrop;

    uint256 public claimFee;

    address public tokenReward;

    constructor(
        uint256 _decimals,
        uint256 _amountAirDrop,
        uint256[] memory _levelRate,
        address _tokenReward,
        uint256 _claimFee
    ) public {
        require(_levelRate.length > 0, "Referral level should be at least one");
        require(
            _levelRate.length <= MAX_REFER_DEPTH,
            "Exceeded max referral level depth"
        );
        require(sum(_levelRate) <= _decimals, "Total level rate exceeds 100%");

        decimals = _decimals;
        levelRate = _levelRate;
        tokenReward = _tokenReward;
        amountAirdrop = _amountAirDrop;
        claimFee = _claimFee;
    }

    function sum(uint256[] memory data) public pure returns (uint256) {
        uint256 S;
        for (uint256 i; i < data.length; i++) {
            S += data[i];
        }
        return S;
    }

    function hasReferrer(address addr) public view returns (bool) {
        return accounts[addr].referrer != address(0);
    }

    function isCircularReference(address referrer, address referee)
    internal
    view
    returns (bool)
    {
        address parent = referrer;

        for (uint256 i; i < levelRate.length; i++) {
            if (parent == address(0)) {
                break;
            }

            if (parent == referee) {
                return true;
            }

            parent = accounts[parent].referrer;
        }

        return false;
    }

    function addReferrer(address referrer) internal returns (bool) {
        require(referrer != address(0), "Referrer cannot be address 0 ");
        require(
            !isCircularReference(referrer, msg.sender),
            "Referee cannot be one of referrer uplines"
        );
        require(
            accounts[msg.sender].referrer == address(0),
            "Address have been registered upline"
        );

        Account storage userAccount = accounts[msg.sender];
        Account storage parentAccount = accounts[referrer];

        userAccount.referrer = referrer;
        parentAccount.referredCount = parentAccount.referredCount.add(1);

        emit RegisteredReferer(msg.sender, referrer);
        return true;
    }

    function claimAirdrop(address referrer) public payable {
        Account storage userAccount = accounts[msg.sender];

        uint256 totalReferral;
        require(msg.value >= claimFee, "Not enough BNB");
        require(!isClaimed[msg.sender], "Already claimed");

        if (referrer == address(0)) {
            IBEP20(tokenReward).safeTransfer(msg.sender, amountAirdrop);
        } else {

            addReferrer(referrer);

            IBEP20(tokenReward).safeTransfer(msg.sender, amountAirdrop);

            for (uint256 i = 0; i < levelRate.length; i++) {
                address parent = userAccount.referrer;
                Account storage parentAccount = accounts[parent];

                if (parent == address(0)) {
                    break;
                }

                uint256 reward = amountAirdrop.mul(levelRate[i]).div(decimals);

                IBEP20(tokenReward).safeTransfer(parent, reward);

                emit PaidReferral(msg.sender, parent, reward, i);

                userAccount = parentAccount;
            }
        }

        isClaimed[msg.sender] = true;

        if (msg.value > claimFee) {
            payable(msg.sender).transfer(msg.value.sub(claimFee));
        }

        emit Claim(msg.sender, referrer, amountAirdrop);

    }

    function setTokenReward(address _tokenReward) public onlyOwner {
        tokenReward = _tokenReward;
    }

    function setTotalAirdrop(uint256 _amountAirdrop) public onlyOwner {
        amountAirdrop = _amountAirdrop;
    }

    function setClaimFee(uint256 _newClaimFee) public onlyOwner {
        claimFee = _newClaimFee;
    }

    function clearAllERC20(IBEP20 token, address to, uint256 amount) external onlyOwner {
        token.safeTransfer(to, amount);
    }

    function clearAllETH(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }
}