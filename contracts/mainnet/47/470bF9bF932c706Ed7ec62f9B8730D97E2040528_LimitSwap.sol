/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity = 0.8.4;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor()  {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// 
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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface Irouter {
      function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        
       function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
        function swapTokensForExactTokens(uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline ) 
        external returns (uint[] memory amounts);
        
       function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract LimitSwap is Ownable{
    
    uint public orderId;
    Irouter public router;
    address public signer;
    bool public lockStatus;
    
    struct userDetails {
        bool initiate;
        bool completed;
        address useraddress;
        uint8 flag;
        address[] path;
        uint depAmt;
        uint fee;
        uint expectAmt;
    }
    
    mapping(uint => userDetails)public users;
    
    event Initialize(uint orderid,uint8 flag,address indexed from,uint amount,uint DepAmt,uint Fee,uint ExpectAmt,address[] path);
    event Swap(address indexed from,uint Orderid,uint8 _flag,uint givenAmt,uint getAmount);
    
    constructor (address _router,address _signer) {
        router = Irouter(_router);
        signer = _signer;
    }
    
    modifier onlySigner() {
        require(msg.sender == signer, "Only signer");
        _;
    }
    
     /**
     * @dev Throws if lockStatus is true
     */
    modifier isLock() {
        require(lockStatus == false, " Contract Locked");
        _;
    }
    
    /**
     * @dev Throws if called by other contract
     */
    modifier isContractCheck(address _user) {
        require(!isContract(_user), "Invalid address");
        _;
    }
    
    function initialize(uint amount,uint _depAmt,uint _fee,address[] memory path,uint8 _flag,uint _expectAmt)public isLock isContractCheck(msg.sender)payable {
        require(_flag == 1 || _flag == 2 || _flag == 3,"Incorrect flag");
        require(_depAmt > 0 && _fee > 0,"Incorrect params");
        orderId++;
        userDetails storage user = users[orderId];
        if (_flag == 1) {
        require(msg.value >= _depAmt + _fee && amount == 0,"Incorrect amt");
        user.depAmt = _depAmt;
        require(payable(owner()).send(_fee),"BNB failed");
        emit Initialize(orderId,_flag,msg.sender,msg.value,_depAmt,_fee,_expectAmt,path);
        }
        else {
        require(amount == _depAmt + _fee && msg.value == 0,"Incorrect amt");
        IBEP20(path[0]).transferFrom(msg.sender,address(this),amount);
        IBEP20(path[0]).transfer(owner(),_fee);
        user.depAmt = _depAmt;
        emit Initialize(orderId,_flag,msg.sender,amount,_depAmt,_fee,_expectAmt,path);
        }
       
        user.initiate = true;
        user.useraddress = msg.sender;
        user.path = path;
        user.fee = _fee;
        user.flag = _flag;
        user.expectAmt = _expectAmt;

    }
    
    function swap(uint _orderId)public onlySigner{
        require(_orderId <= orderId && _orderId!= 0,"Incorrect id");
        userDetails storage user = users[_orderId];
        require(!user.completed,"Already completed");
        uint inAmt = _update(_orderId);
        if (user.flag == 1){
            router.swapETHForExactTokens{value: inAmt}(
               user.expectAmt,
               user.path,
               user.useraddress,
               block.timestamp + 900
            );
        } 
        else if(user.flag == 2) {
            IBEP20(user.path[0]).approve(address(router),inAmt);
            router.swapTokensForExactETH(
              user.expectAmt,
              inAmt,
              user.path,
              user.useraddress,
              block.timestamp + 900
            );
        }

        else if(user.flag == 3) {
            IBEP20(user.path[0]).approve(address(router),inAmt);
            router.swapTokensForExactTokens(
              user.expectAmt,
              inAmt,
              user.path,
              user.useraddress,
              block.timestamp + 900
            );
        }

        user.completed = true;
        emit Swap(user.useraddress,_orderId,user.flag,inAmt,user.expectAmt);
    }
    
    function _update(uint _orderid)internal returns(uint value){
        userDetails storage user = users[_orderid];
          if (user.flag == 1){
              uint[] memory amt = router.getAmountsIn(user.expectAmt,user.path);
              if (amt[0] < user.depAmt) {
                  require(payable(user.useraddress).send(user.depAmt - amt[0]),"Remainig failed");
                  return amt[0];
              }
              else return amt[0];
              
          }
          else {
              uint[] memory amt = router.getAmountsIn(user.expectAmt,user.path);
              if (amt[0] < user.depAmt) {
                  require(IBEP20(user.path[0]).transfer(user.useraddress,user.depAmt - amt[0]),"Remainig failed");
                  return amt[0];
              }
              else return amt[0];
          }
    }
    
    function viewPath(uint _id)public view returns(address[] memory) {
        return users[_id].path;
    }
    
    function updateAddress(address _signer)public onlyOwner {
        signer = _signer;
    }
    
    function retrive(uint8 _flag,address _toUser,uint _amount,address _token)public onlyOwner {
        require(_toUser != address(0),"Invalid address");
        require(_amount > 0 && _flag == 1 || _flag ==2 || _flag ==3,"Incorrect params");
        if (_flag == 1) {
            require(_amount <= address(this).balance,"Invalid amount");
            require(payable(_toUser).send(_amount),"Send failed");
        }
        else {
             require(_token != address(0),"Invalid addr");
             require(_amount <= IBEP20(_token).balanceOf(address(this)),"Not enough balance");
             require(IBEP20(_token).transfer(_toUser,_amount),"transfer failed");
        }
    }
    
    function contractLock(bool _lockStatus) public onlyOwner returns(bool) {
        lockStatus = _lockStatus;
        return true;
    }
    
    function isContract(address _account) public view returns(bool) {
        uint32 size;
        assembly {
            size:= extcodesize(_account)
        }
        if (size != 0)
            return true;
        return false;
    }

}