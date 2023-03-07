/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at Arbiscan on 2023-02-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

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

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
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
    using SafeMath for uint256;
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IOwnable {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner_) external;
}

contract Ownable is IOwnable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual override onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner_)
    public
    virtual
    override
    onlyOwner
    {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner_);
        _owner = newOwner_;
    }
}

abstract contract ReentrancyGuard {
    ///布尔类型比uint256或任何占用一个full
//因为每次写操作都会触发一个额外的SLOAD来首先读取
// slot的内容，替换布尔所占用的位，然后写入
//返回。这是编译器对契约升级和的防御

//指针别名，不能禁用。


//如果值为非零，则部署会更加昂贵，
//但作为交换，每次呼叫nonReentrant的退款将降低
//金额。因为退款的上限是总额的一个百分比
//交易的gas，在这种情况下，最好将它们保持低，以

//增加全额退款生效的可能性。

 
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // 在第一次调用nonReentrant时，_notEntered将为true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        //此后对nonReentrant的任何调用将失败
        _status = _ENTERED;

        _;

        // 通过再次存储原始值，将触发退款(参见
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract IDO is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //token
    address public PayOutToken;

    //支付
    address public USDT;

    mapping(address => address) public one;  
    mapping(address => address) public two;
    mapping(address => address) public three;
    mapping(address => address) public four;


    struct inviteInfo{
        address addr;
        uint256 id;
        uint256 amount; 
        uint256 award;
    }
    
    mapping(address => inviteInfo[]) public invite;

    //amount
    uint256 public MaxIDOPayInAmount = 900000000000000000000000; // 90w u
    uint256 public receivedIDOPayInAmount;

    //uint256 public MinhitelistSinglePayInAmount = 300000000000000000; // 0.3 ETH
    uint256 public MaxWhitelistSinglePayInAmount = 180000000000000000000; // 180u
    mapping(address => uint256) public whitelistPayInAmountCounter; //记录支付的usdt数量
    mapping(address => uint256) public whitelistPurchaseAmount;


    //time
    uint256 public IDOStartTimestamp;
    uint256 public IDOEndTimestamp;
    uint256 public ClaimStartTimestamp;

    //price
    uint256 public whiteListPrice = 111111111111111100000000000; // 1u等于多少代币

  


    //switch
    bool public saleStarted;


    constructor() {
        IDOStartTimestamp = 1678035600;
        IDOEndTimestamp = 1678208400;
        ClaimStartTimestamp = 1678208400;
        PayOutToken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    }
    receive() external payable {

    }
    /* mapping(address => bool) public whiteListed;

    function addWhiteLists(address[] memory _buyers)
    external
    onlyOwner
    returns (bool)
    {
        for (uint256 i; i < _buyers.length; i++) {
            whiteListed[_buyers[i]] = true;
        }
        return true;
    } */

     
    


    function setStart() external onlyOwner returns (bool) {
        saleStarted = !saleStarted;
        return saleStarted;
    }


    function calWitheListPayOut(uint256 _payInAmount) public view returns (uint256) {
        return _payInAmount.mul(10 ** 18).div(whiteListPrice);
    }





    function buy(uint256 amount,address inviteAddress) nonReentrant  public {
  
        //最小限制
       /*  if (whitelistPurchaseAmount[msg.sender] == 0) {
            require(amount >= MinhitelistSinglePayInAmount, "Minimum buy amount: 0.3 ETH");
        } else if (whitelistPurchaseAmount[msg.sender] < MinhitelistSinglePayInAmount) {
            require(amount >= MinhitelistSinglePayInAmount.sub(whitelistPurchaseAmount[msg.sender]), "Minimum buy amount: 0.3 ETH");
        } */

        
        require(block.timestamp >= IDOStartTimestamp, "IDO is upcoming"); //开始时间
        require(block.timestamp <= IDOEndTimestamp, "IDO is closed"); //结束时间
        require(
            receivedIDOPayInAmount.add(amount) <= MaxIDOPayInAmount,
            "Amount exceed the Fundraise Goal"
        ); //总私募量必须小于设置的最大数量

        //require(whiteListed[msg.sender], "Not in whiteList"); //检测是否是白名单
        //不能大于最大私募量
        require(MaxWhitelistSinglePayInAmount >= amount + whitelistPayInAmountCounter[msg.sender], "Maximum buy amount: 180 USDT");

        //收取usdt
        IERC20(USDT).transferFrom(msg.sender,address(this),amount);

         uint256 payOutAmount = calWitheListPayOut(amount);

        //记录获得的代币数
        whitelistPurchaseAmount[msg.sender] = whitelistPurchaseAmount[msg.sender].add(payOutAmount);
        //记录支付的usdt数量
        whitelistPayInAmountCounter[msg.sender] = whitelistPayInAmountCounter[msg.sender].add(amount);

         if(inviteAddress!=address(0)){
             //首先设置一级邀请
       one[msg.sender] = inviteAddress; 
       whitelistPurchaseAmount[inviteAddress] = whitelistPurchaseAmount[inviteAddress].add((payOutAmount*2)/100);
       invite[inviteAddress].push(inviteInfo(msg.sender,1,amount,(payOutAmount*2)/100));

       //查询一级邀请者的上级
       address oneAddress = one[inviteAddress];
       if(oneAddress != address(0)){
            //赋值二级邀请
            two[msg.sender] = oneAddress; 
            whitelistPurchaseAmount[oneAddress] = whitelistPurchaseAmount[oneAddress].add((payOutAmount*2)/100);
            invite[oneAddress].push(inviteInfo(msg.sender,2,amount,(payOutAmount*2)/100));

            //查询二级邀请者的上级  
            address twoAddress =  one[oneAddress];
            if(twoAddress != address(0)){
                //赋值三级邀请
                three[msg.sender] = twoAddress;
                whitelistPurchaseAmount[twoAddress] = whitelistPurchaseAmount[twoAddress].add((payOutAmount*3)/100);
                invite[twoAddress].push(inviteInfo(msg.sender,3,amount,(payOutAmount*3)/100));

                //查询三级邀请者的上级  
                address threeAddress =  one[twoAddress]; 
                if(threeAddress != address(0)){
                    //赋值三级邀请
                    four[msg.sender] = threeAddress; 
                    whitelistPurchaseAmount[threeAddress] = whitelistPurchaseAmount[threeAddress].add((payOutAmount*5)/100);
                    invite[threeAddress].push(inviteInfo(msg.sender,4,amount,(payOutAmount*5)/100));
                }
            }
       }

      }
        

       


        receivedIDOPayInAmount += amount; //记录已募的usdt数量
    }


    function claim() nonReentrant external {
        require(block.timestamp > ClaimStartTimestamp, "Claim is upcoming");
        require(PayOutToken != address(0), "PayOutToken is not set");
        //require(whiteListed[msg.sender], "Not in whiteList");
        //可获得的代币是否大于0
        require(whitelistPurchaseAmount[msg.sender] > 0, "No EDE to claim");

        IERC20(PayOutToken).transfer(msg.sender,whitelistPurchaseAmount[msg.sender]);
        whitelistPurchaseAmount[msg.sender] = 0;
    }


    function withdraw(
        address _erc20,
        address _to,
        uint256 _val
    ) external onlyOwner returns (bool) {
        IERC20(_erc20).safeTransfer(_to, _val);
        return true;
    }

    function withdrawETH(address payable recipient) external onlyOwner {
        (bool success,) = recipient.call{value : address(this).balance}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    //set USDT
    function setUSDT(address _USDT) external onlyOwner returns (bool) {
        USDT = _USDT;
        return true;
    }

    //set PayOutToken
    function setPayOutToken(address _PayOutToken) external onlyOwner returns (bool) {
        PayOutToken = _PayOutToken;
        return true;
    }

    //set MaxIDOPayInAmount
    function setMaxIDOPayInAmount(uint256 _MaxIDOPayInAmount) external onlyOwner returns (bool) {
        MaxIDOPayInAmount = _MaxIDOPayInAmount;
        return true;
    }

    //set MaxWhitelistSinglePayInAmount
    function setMaxWhitelistSinglePayInAmount(uint256 _MaxWhitelistSinglePayInAmount) external onlyOwner returns (bool) {
        MaxWhitelistSinglePayInAmount = _MaxWhitelistSinglePayInAmount;
        return true;
    }

    //set time
    function setIDOTimestamp(uint256 _IDOStartTimestamp, uint256 _IDOEndTimestamp) external onlyOwner returns (bool) {
        require(_IDOStartTimestamp > block.timestamp, "IDOStartTimestamp error");
        require(
            _IDOEndTimestamp > _IDOStartTimestamp,
            "IDOEndTimestamp error"
        );
        IDOStartTimestamp = _IDOStartTimestamp;
        IDOEndTimestamp = _IDOEndTimestamp;
        return true;
    }

    //set ClaimStartTimestamp
    function setClaimStartTimestamp(uint256 _ClaimStartTimestamp) external onlyOwner returns (bool) {
        require(_ClaimStartTimestamp > block.timestamp, "ClaimStartTimestamp error");
        ClaimStartTimestamp = _ClaimStartTimestamp;
        return true;
    }

    //set price
    function setPrice(uint256 _whiteListPrice) external onlyOwner returns (bool) {
        require(_whiteListPrice > 0, "whiteListPrice error");
        whiteListPrice = _whiteListPrice;
        return true;
    }
}