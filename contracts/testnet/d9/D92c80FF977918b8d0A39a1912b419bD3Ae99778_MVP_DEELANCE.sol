/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

struct Transaction {
  uint256 ID;
  address freelance;
  address client;
  uint256 time;
  uint256 ok_freelance;
  uint256 ok_client;
  uint256 can_be_withdraw;
  uint256 escrow;
  uint256 dispute;
  uint256 complete;
}

struct Freelance {
    address wallet;
    uint256 withdrawed;
    uint256[] contracts;
}

struct Client {
    address wallet;
    uint256[] contracts;
}
contract MVP_DEELANCE {
    using SafeERC20 for IERC20;

    address public owner;
    uint256 public transaction_id;

    IERC20 public BUSD;
    IERC20 public ANYTOKEN;
    
    mapping(address => Freelance) public freelancer;
    mapping(uint256 => Transaction) public transactions;
    mapping(address => Client) public clients;

    event New_Deal(address indexed client, address indexed freelance, uint256 escrow);
    event Withdraw_Freelance(uint256 ID, address indexed freelance, uint256 time, uint256 escrow);
    event Dispute_solved(uint256 ID, uint256 time);
    event New_Dispute (uint256 ID, uint256 time, address indexed client);
    event Ok_Client (uint256 ID, address indexed client);
    event Ok_Freelance(uint256 ID, address indexed freelance);

    constructor() {
        owner = msg.sender;
        BUSD = IERC20(0xf1590C5F3100AdeEf123D0CB8954058902A81bb8);
        transaction_id = 0;
    }

    function transferAnyERC20Tokens(address _tokenAddress, uint256 _amount) public  {
            require(msg.sender == owner, "You are not allowed to do this!");
            ANYTOKEN = IERC20(_tokenAddress);
            ANYTOKEN.safeTransfer(msg.sender, _amount);
    }
    
    function create_transaction(address client_address, address freelance_address, uint256 escrow) external {
        require(escrow >= 1 ether, "Minimum deposit amount is 1 BUSD");
        transaction_id++;
        Transaction storage transaction = transactions[transaction_id];
        Freelance storage freelance = freelancer[freelance_address];
        Client storage client = clients[client_address];
        //rimuovo fee
        //uint256 fee_client = 2 * escrow / 100;
        //fee_client = escrow - fee_client;
        //BUSD.transfer(owner, fee_client);
        //nuovo escrow
        //escrow = escrow - fee_client;
        //conservo la transazione
        transaction.ID = transaction_id;
        transaction.freelance = freelance_address;
        transaction.client = client_address;
        transaction.escrow = escrow;
        transaction.time = block.timestamp;
        transaction.complete = 0;
        freelance.wallet = freelance_address;
        client.wallet = client_address;
        client.contracts.push(transaction_id);
        freelance.contracts.push(transaction_id);
        
        BUSD.safeTransferFrom(client_address, address(this), escrow);

        emit New_Deal(client_address, freelance_address, escrow);
    }

    function withdraw_transaction(uint256 ID) external  {
    Transaction storage transaction = transactions[ID];
    require(transaction.freelance == msg.sender, "You are not the freelance of this transaction");
    require(transaction.ok_client == 1, "The client didn't approve the payment.");
    require(transaction.dispute < 1, "There is a Dispute on this transaction");
    require((block.timestamp * 1 days) >= transaction.time, "The time is not come!");
    require(transaction.complete < 1, "Transaction already complete and pay!");
    
    //uint256 fee_freelance = 10 * transaction.escrow / 100;
    //BUSD.safeTransfer(owner, fee_freelance);
    //uint256 escrow = transaction.escrow - fee_freelance;
    BUSD.safeTransfer((transaction.freelance), transaction.escrow);

    transaction.complete = 1;

    Freelance storage freelance = freelancer[transaction.freelance];
    freelance.withdrawed += transaction.escrow;

    emit Withdraw_Freelance(ID, transaction.freelance, block.timestamp, transaction.escrow);
    }

    function set_Ok_Client (uint256 ID) external {
    Transaction storage transaction = transactions[ID];
    require(transaction.client == msg.sender, "You are not the Client of this Transaction");
    require(transaction.complete < 1, "Transaction already complete and pay!");
    require(transaction.dispute < 1, "There is a Dispute on this transaction");

    transaction.ok_client = 1;
    transaction.can_be_withdraw = (block.timestamp * 1 days) + 3 days;
    emit Ok_Client(ID, transaction.client);
    }

    function set_Ok_Freelance (uint256 ID) external {
    Transaction storage transaction = transactions[ID];
    require(transaction.freelance == msg.sender, "You are not the Freelance of this Transaction");
    require(transaction.complete < 1, "Transaction already complete and pay!");
    require(transaction.dispute < 1, "There is a Dispute on this transaction");

    transaction.ok_freelance = 1;
    transaction.can_be_withdraw = (block.timestamp * 1 days) + 10 days;
    emit Ok_Freelance(ID, transaction.freelance);
    }
   
    function create_dispute (uint256 ID) external {
    Transaction storage transaction = transactions[ID];
    require(transaction.client == msg.sender, "You are not the Client of this Transaction");  
    require(transaction.complete < 1, "Transaction already complete and pay!");
    
    transaction.dispute = 1;

    emit New_Dispute (ID, block.timestamp, transaction.client);
    }

    function resolve_dispute (uint256 ID) external {
    Transaction storage transaction = transactions[ID];
    require(msg.sender == owner, "You are not a moderator!");
    transaction.dispute = 0;
    
    emit Dispute_solved(ID, block.timestamp);
    }


}