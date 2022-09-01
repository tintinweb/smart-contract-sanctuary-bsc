// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import {IERC20} from "./interfaces/IERC20.sol";


/// @dev this contract is a time lock contract for an erc20 token, the lock duration would be specified during the contract deployment
/// @author developeruche
contract Timelock {
    address public immutable lockToken; // this is the address of the token the manager want to lock (NRF)
    address public admin;
    uint256 public lockTime; // this is the duration the tokens would be locked for in this contract
    bool public isTokenLocked;



    // CUSTOM ERRORS
  

    /// Token is currently locked in contract
    error TokenIsCurrentlyLocked();
    /// Token transfer was not successful
    error TokenNotTransfered();
    /// Withdraw time is yet to come
    error NotWithdrawalTime();
    /// You are not an admin
    error NotAdmin();
    /// Cannot Perform this operation
    error WrongAction();


    // MODIFIERS

    modifier OnlyAdmin() {
        if(msg.sender != admin) {
            revert NotAdmin();
        }
        _;
    }




    // EVENTS
    event Deposited(address depositor, uint256 amount);
    event Withdrawal(address manager, uint256 amount);



    

    /// @param _lockToken: this is the address of the token you 
    constructor(address _lockToken) {
        lockToken = _lockToken;
        admin = msg.sender;
    }

    /// @dev this function would transfer the erc20 tokens from the caller and lock it in this contract
    /// @notice this function would revert if the contract has not ben approved to spend this amount of tokens
    /// @param _tokenAmount: this is the amount of token the msg.sender wishes to lock in this contract 
    /// @param _lockTime: this is the duration of time (In years) the token would be locked for in this contract
    function makeDeposit(uint256 _tokenAmount, uint256 _lockTime) public OnlyAdmin {
        if(isTokenLocked) {
            revert TokenIsCurrentlyLocked();
        }

        if(_lockTime > 5) {
            revert WrongAction();
        }

        uint256 balanceBeforeTransfer = IERC20(lockToken).balanceOf(address(this));

        // transfering the tokens
        bool recieved = IERC20(lockToken).transferFrom(msg.sender, address(this), _tokenAmount);

        if(!recieved) {
            revert TokenNotTransfered();
        }

        // confirming transfer
        uint256 balanceAfterTransfer = IERC20(lockToken).balanceOf(address(this));

        if(balanceBeforeTransfer + _tokenAmount != balanceAfterTransfer) {
            revert TokenNotTransfered();
        }

        uint256 lockYear =  365 days * _lockTime;
        lockTime = block.timestamp + lockYear; // converting the lock time into second relational to the block.timestamp

        isTokenLocked = true;
        emit Deposited(msg.sender, _tokenAmount);
    }

    /// @dev this function would tranfer the _amount of token specified to the _receiver provided the lock time is satified
    /// @param _amount: thisis the amount of token the admin want to withdraw 
    /// @param _receiver: this is the address that would be recieving the token
    function withdrawTokens(uint256 _amount, address _receiver) public OnlyAdmin {
        if(block.timestamp < lockTime) {
            revert NotWithdrawalTime();
        }

        // getting to this point means the time to withdraw is satisfied
        bool sent = IERC20(lockToken).transfer(_receiver, _amount); // for the sake of flexibility the admin can indicate an address he want to transfer the token to

        if(!sent) {
            revert TokenNotTransfered();
        }

        emit Withdrawal(msg.sender, _amount);
    }


    /// @dev this function would give the admin functionality to the _newOwner
    /// @param _newOwner: this is the address that would be the new owner
    function transferOwnership(address _newOwner) public OnlyAdmin {
        admin = _newOwner;
    }


    /// @dev this function would move any ERC20 token that is transfered to this address
    /// @param _receiver: this is the address that would be receiving the tokens 
    /// @param _tokenContractAddress: this is the address of the erc 20 contract 
    /// @param _amount: this is the amount of token the manager want to get out of this contract
    function movingGeneric(address _receiver, address _tokenContractAddress, uint256 _amount) public OnlyAdmin {
        if(_tokenContractAddress == lockToken) {
            revert WrongAction();
        }
        IERC20(_tokenContractAddress).transfer(_receiver, _amount); // this would transfer the token from the contract to the address
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
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