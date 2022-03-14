/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
// File: IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    function mint(address caller, uint256 amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burn(address from, uint256 amount) external;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: bnbBridge.sol





contract BinanceBridge {
  IERC20 private bnbToken;
 
        struct getDetailsByHashDetail{
        bytes32 getDetailsByHash;
        address user;
        uint amount;
        uint bridgetime;
    }
    event BridgeInitialized(uint256 indexed timestamp);
    event TokensBridged(
        address indexed requester,
    
        uint256 amount,
        uint256 timestamp
    );
    event TokensReturned(
        address indexed requester,
        bytes32 indexed sideDepositHash,
        uint256 amount,
        uint256 timestamp
    );

   
 
    bool bridgeInitState;
    address owner;
    address gateway;
 mapping(bytes32 => uint) public ethamount;
    mapping(bytes32 =>getDetailsByHashDetail ) public getDetailsByHash;
  
mapping (address=> mapping (bytes32=> uint)) public aamount;
    function initializeToken(address _childTokenAddress) external  {
        bnbToken = IERC20(_childTokenAddress);
        bridgeInitState = true;
    }

    function bridgeTokens(
        address _requester,
        uint aaamount
      
    ) external  onlyGateway {
    
        IERC20(bnbToken).mint(_requester, aaamount);
        emit TokensBridged(
            _requester,
            
            aaamount,
            block.timestamp
        );
    }
  function setGateway(address __gateway) public {
        gateway = __gateway;
    }

    function getGateway() public view returns (address) {
        return gateway;
    }
 function bal(address addr) public view returns (uint256 balance) {
        balance = bnbToken.balanceOf(addr);
        return balance;
    }
    function returnTokens(
        address _requester,
        uint256 _bridgedAmount,
        bytes32 _sideDepositHash
    ) external   {
        IERC20(bnbToken).burn(_requester, _bridgedAmount);
        emit TokensReturned(
            _requester,
            _sideDepositHash,
            _bridgedAmount,
            block.timestamp
        );
    }
 function lockTokens(
        address _requester,
        uint256 _bridgedAmount
    ) external onlyGateway {
       
        require (_bridgedAmount >= 100 ||_bridgedAmount <= 1000 , " min 100 and max 1000");
       bytes32  getDetailsByHashh = keccak256(abi.encodePacked(_requester, _bridgedAmount));
       uint time = block.timestamp;
       getDetailsByHash[getDetailsByHashh] = getDetailsByHashDetail(getDetailsByHashh,
       _requester,
       _bridgedAmount,
       time
       );
       ethamount[getDetailsByHashh] = _bridgedAmount;
        IERC20(bnbToken).burn(_requester, _bridgedAmount);
        emit TokensLocked(
            _requester,
            _bridgedAmount,
            block.timestamp,
            getDetailsByHashh
        );
    }
    // modifier verifyInitialization() {
    //     require(bridgeInitState, "Bridge has not been initialized");
    //     _;
    // }

    modifier onlyGateway() {
        require(
            msg.sender == gateway,
            "Only gateway can execute this function"
        );
        _;
    }

    // modifier onlyOwner() {
    //     require(msg.sender == owner, "Only owner can execute this function");
    //     _;
    // }
    event TokensLocked(
        address indexed requester,
        uint256 amount,
        uint256 timestamp,
        bytes32 indexed mainDepositgetDetailsByHash

    );
    event TokensUnlocked(
        address indexed requester,
        bytes32 indexed sideDepositgetDetailsByHash,
        uint256 amount,
        uint256 timestamp
    );
}