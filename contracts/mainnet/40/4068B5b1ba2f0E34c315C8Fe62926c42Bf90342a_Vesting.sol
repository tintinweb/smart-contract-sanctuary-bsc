// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import {IERC20} from "./interfaces/IERC20.sol";


/// @author developeruche
/// @dev this is a vesting contract, withdrawal can be done every month
contract Vesting {
    uint256 public constant VESTING_TIME = 30 days;
    uint256 public constant VESTING_PERCENT = 4167; // for no token to be left in contract after vesting period, 100,008 should be vested
    address public tokenAddress;
    address public manager;
    uint256 public vestedAmount;
    mapping(uint256 => uint256) private lastWithdrawal;
    uint256 public nonce; // this is the number of times withdrawal
    bool public hasVested;


    /// @param _tokenAddress: this is the contract address that is to be vested 
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        manager = msg.sender;
    }


    // ERROR

    /// Token Transfer Failed 
    error TransferFailed();
    /// Wrong withdrawal time
    error WithdrawalTime();
    /// You are not an admin
    error NotAdmin();
    /// Cannot Perform this operation
    error WrongAction();
    /// Cannot vest again
    error CannotVest();
    /// Cannot vest zero
    error CannotVestZero();



    // MODIFIERS

    modifier OnlyAdmin() {
        if(msg.sender != manager) {
            revert NotAdmin();
        }
        _;
    }


    // EVENTS
    event MonthlyWithdrawal(address receiver, uint256 amount);
    event Vested(address manager, uint256 amount);



    /// @dev this is the function to hit to start the vesting
    /// @param _amount: this is the amount of token the user wishes to vest
    /// @notice this function would revert if the contract has not be approved to spend the users token 
    function makeVest(uint256 _amount) public OnlyAdmin {
        if(hasVested) {
            revert CannotVest();
        }
        if(_amount == 0) {
            revert CannotVestZero();
        }

        // transfering the fund from the manager to the contract
        bool transfered = IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

        // confirmation of withdrawal 
        if(!transfered) {
            revert TransferFailed();
        }

        lastWithdrawal[nonce] = block.timestamp; // this would be a mapping of (0 => block.timestamp) when user is withdrawaling, a check for 30day would be done with this 


        vestedAmount = _amount;

        hasVested = true;
        emit Vested(msg.sender, _amount);
    }

    /// @dev this function would be called to make the monthly withdrawal 
    /// @notice this function would revert if the function if called before the next withdraw period
    function monthlyWithdrawal(address _receiver) public OnlyAdmin {
        if( block.timestamp < lastWithdrawal[nonce] + VESTING_TIME) {
            revert WithdrawalTime();
        }
        uint256 payment = (VESTING_PERCENT * vestedAmount) / (100000);
        bool sent = IERC20(tokenAddress).transfer(_receiver, payment);

        if(!sent) {
            revert TransferFailed();
        }
        nonce++;
        lastWithdrawal[nonce] =  lastWithdrawal[nonce - 1] + VESTING_TIME;

        emit MonthlyWithdrawal(_receiver, payment);
    }

    /// @dev this function would move any ERC20 token that is transfered to this address
    /// @param _receiver: this is the address that would be receiving the tokens 
    /// @param _tokenContractAddress: this is the address of the erc 20 contract 
    /// @param _amount: this is the amount of token the manager want to get out of this contract
    function movingGeneric(address _receiver, address _tokenContractAddress, uint256 _amount) public OnlyAdmin {
        if(_tokenContractAddress == tokenAddress) {
            revert WrongAction();
        }
        IERC20(_tokenContractAddress).transfer(_receiver, _amount); // this would transfer the token from the contract to the address
    }

    /// @dev this function would give the admin functionality to the _newOwner
    /// @param _newOwner: this is the address that would be the new owner
    function transferOwnership(address _newOwner) public OnlyAdmin {
        manager = _newOwner;
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