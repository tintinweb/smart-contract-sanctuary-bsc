// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';


contract RIM_Pool_Game_Lock {
  using SafeMath for uint256;
  // Todo : Update when deploy to production

  address public tokenLock;
  address public releaseToAddress;
  address public admin1;
  address public admin2;
  address public admin3;
  address public owner;

  uint256 public vote1 = 0;
  uint256 public vote2 = 0;
  uint256 public vote3 = 0;

  uint256 public totalClaimed=0;

  event ClaimAt(address indexed userAddress, uint256 indexed claimAmount);
  event AdminVote(address indexed adminAddress, uint256 indexed vote);
  event AdminUnvote(address indexed adminAddress, uint256 indexed vote);
  event ChangeReleaseAddress(address indexed newAddress, address indexed oldAddress);


  modifier onlyAmin() {
    require(msg.sender == admin1 || msg.sender == admin2 || msg.sender == admin3 , 'INVALID ADMIN');
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner  , 'INVALID OWNER');
    _;
  }

  constructor(address _tokenLock, address _releaseToAddress) public {    
        owner = tx.origin;  
        tokenLock = _tokenLock;
        // Mainnet
        releaseToAddress = _releaseToAddress;
        admin1 = 0x7888C7E4614E00E11f3e0aa2Cf3062eAA593bAD0;
        admin2 = 0x12b442FA479105EA97FF32Ae507Edd8c3cC926Be;
        admin3 = 0xae8F93529BEa589688b7Cee29bCDc303b83dF508;
  }

    
    /**
     * @dev vote releaseToAddress of the contract to a new releaseToAddress .
     * Can only be called by the current admin .
     */
    function vote(uint256 amount) public onlyAmin {
        if(msg.sender==admin1)
        {
            vote1 = amount;
            emit AdminVote(msg.sender,vote1);
            
        }
        if(msg.sender==admin2)
        {
            vote2 = amount;
            emit AdminVote(msg.sender,vote2);
            
        }
        if(msg.sender==admin3)
        {
            vote3 = amount;
            emit AdminVote(msg.sender,vote3);
        }
        
    }

    function changeReleaseAddress(address _releaseToAddress) public onlyOwner {
            require(vote1 == 1 &&  vote2 == 1 &&  vote3 == 1 , "Need 3 vote");    
            emit ChangeReleaseAddress( releaseToAddress , _releaseToAddress );
            releaseToAddress = _releaseToAddress;   
            vote1 = 0;
            vote2 = 0;
            vote3 = 0;
    }

    /**
     * @dev vote releaseToAddress of the contract to a new releaseToAddress .
     * Can only be called by the current admin .
     */
    function unvote() public onlyAmin {
        if(msg.sender==admin1)
        {
            vote1 = 0;
            emit AdminUnvote(msg.sender,vote1);
            
        }
        if(msg.sender==admin2)
        {
            vote2 = 0;
            emit AdminUnvote(msg.sender,vote2);
            
        }
        if(msg.sender==admin3)
        {
            vote3 = 0;
            emit AdminUnvote(msg.sender,vote3);
        }     
    }
  
    
  
  function clearToken( address token) public onlyOwner   {
    require(token != tokenLock, "Only clear token unlock");      
    IERC20(token).transfer( owner , IERC20(token).balanceOf(address(this)));
  }
  
   
  function clearBNB() public onlyOwner   {
    _safeTransferBNB(owner, address(this).balance);
  }


  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'BNB_TRANSFER_FAILED');
  }

  /**
   * @dev owner claim 
   */
   
   function TransferRIMToPoolGame(uint256 amount) public onlyAmin returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        require(( vote1 == vote2 && vote1 > 0 ) || ( vote1 == vote3 && vote1 > 0 ) 
        || ( vote2 == vote3 && vote2 > 0 ),"Require 2 vote amount from admin");
        require(( vote1 == amount && vote1 > 0 ) || ( vote3 == amount && vote3 > 0 ) 
        || ( vote2 == amount && vote2 > 0 ),"Require amount equal vote amount");
        uint256 balanceToken = IERC20(tokenLock).balanceOf(address(this));
        amount = amount * 10**18;
        require(balanceToken >= amount, "Sorry: no tokens to release");   
        require(amount >= 1, "Sorry: minium 1 token");
        IERC20(tokenLock).transfer(releaseToAddress,amount);
        emit ClaimAt(releaseToAddress,amount);
        totalClaimed += amount / 10**18;
        vote1 = 0;
        vote2 = 0;
        vote3 = 0;
        return amount;
   }
  
}