/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
//pragma solidity ^0.4.21;
pragma solidity ^0.8.10;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



contract MultiSigTokenWallet {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address  erc20 ,
        address indexed to,
        uint value,
        bytes data
    );

    event   submitHolderEvent(address indexed senderAddress,address indexed holder);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);

    event ConfirmHolderTransaction(address indexed owner, uint indexed txIndex);


    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    uint private removeOwnerCnt=0;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;
    
    struct Transaction {
        address  erc20;
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }


   struct TransactionHolder {
        address holderAddress;
        bool executed;
        uint numConfirmations;
        uint changeConfirmCount;
        uint addOrSub;
         
    }

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    mapping(uint => mapping(address => bool)) public isHolderConfirmed;



    Transaction[] public transactions;
   
    TransactionHolder[] public holderTransactions;
    
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }


   modifier txHolderExists(uint _txIndex) {
        require(_txIndex < holderTransactions.length, "tx does not exist");
        _;
    }


    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }


    modifier notHolderExecuted(uint _txIndex) {
        require(!holderTransactions[_txIndex].executed, "tx already executed");
        _;
    }



    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    modifier notHolderConfirmed(uint _txIndex) {
        require(!isHolderConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }



    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;

       // usdt =    IERC20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee) ); 
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address erc20,
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                erc20: erc20,
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, erc20,_to, _value, _data);
    }



    function submitHolder( address holderAddress ,uint changenumConfirmations, uint addOrSub ) public onlyOwner {
        holderTransactions.push(
            TransactionHolder({
                holderAddress: holderAddress,
                executed: false,
                numConfirmations: 0,
                changeConfirmCount:changenumConfirmations,
                addOrSub: addOrSub
            })
        );
        emit submitHolderEvent(msg.sender,  holderAddress );
    }


    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }



  function confirmHolderTransaction(uint _txIndex)
        public
        onlyOwner
        txHolderExists(_txIndex)
        notHolderExecuted(_txIndex)
        notHolderConfirmed(_txIndex)
    {
        TransactionHolder storage transactionHolder = holderTransactions[_txIndex];
        transactionHolder.numConfirmations += 1;
        isHolderConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmHolderTransaction(msg.sender, _txIndex);
    }


    function executeHolderTransaction(uint _txIndex)
        public
        onlyOwner
        txHolderExists(_txIndex)
        notHolderExecuted(_txIndex)
    {
        
        TransactionHolder storage transactionHolder = holderTransactions[_txIndex];

        require(
            transactionHolder.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        //验证修改的参数  设置最小不能为1  最大不能超过
        require(transactionHolder.changeConfirmCount <= (owners.length-removeOwnerCnt) && transactionHolder.changeConfirmCount>=1);

        transactionHolder.executed = true;
        
        if(transactionHolder.addOrSub ==1){
            //增加人

            owners.push(transactionHolder.holderAddress);
            // mapping(address => bool) public isOwner;
            isOwner[transactionHolder.holderAddress] = true;
            //设置执行数量
            numConfirmationsRequired = transactionHolder.changeConfirmCount;
        }else if(transactionHolder.addOrSub == 2 ){
            //减少人
            isOwner[transactionHolder.holderAddress] = false;
            //设置执行数量
            numConfirmationsRequired = transactionHolder.changeConfirmCount;
            removeOwnerCnt--;
        }
        
        emit ExecuteTransaction(msg.sender, _txIndex);
    }



    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;
        IERC20(transaction.erc20 ).safeTransfer( transaction.to, transaction.value);
        

        emit ExecuteTransaction(msg.sender, _txIndex);
    }








    event event_executeTransfer(address toaddress,uint256 value);

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        if(transaction.numConfirmations < numConfirmationsRequired){
            isConfirmed[_txIndex][msg.sender] = false;
            emit RevokeConfirmation(msg.sender, _txIndex);
        }
               
    }

function revokeHolderConfirmation(uint _txIndex)
        public
        onlyOwner
        txHolderExists(_txIndex)
        notHolderExecuted(_txIndex)
    {
        

        TransactionHolder storage transactionHolder = holderTransactions[_txIndex];

        require(isHolderConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transactionHolder.numConfirmations -= 1;
        if(transactionHolder.numConfirmations < numConfirmationsRequired){
            isHolderConfirmed[_txIndex][msg.sender] = false;
            emit RevokeConfirmation(msg.sender, _txIndex);
        }
               
    }



    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}

contract token { 
        function  transfer(address receiver, uint amount) public pure { receiver; amount; } 
}