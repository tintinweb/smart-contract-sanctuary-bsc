//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./IERC20.sol";

interface IOwnedContract {
    function getOwner() external view returns (address);
}


contract FeeReceiver {
    // Token
    address public constant DUMP = 0x6b8a384DDe6FC779342Fbb2E4a8EcF73eD18D151;
    address public immutable PancakeLP;

    // Recipients Of Fees
    address public addr0 = 0xb49844F55c08C0aF57A9FBf71Fb5747aDe7dA8c4; 
    address public addr1 = 0x5A985Bb05B9B2f1a0b7343450bFD2625Fb02d2b9; 
    address public addr2 = 0x06aCBafA2dCAb16512a0Dc417eabFf7A8881774f; 
    

    // bounty percent
    uint256 public bountyPercent = 1;


    modifier onlyOwner() {
        require(
            msg.sender == IOwnedContract(DUMP).getOwner(),
            "Only Token Owner"
        );
        _;
    }

    constructor(address PancakeLP_) {
        PancakeLP = PancakeLP_;
    }

    function trigger() external {
        // Bounty Reward For Triggerer
        uint256 bounty = currentBounty();
        if (bounty > 0) {
            _send(msg.sender, bounty);
        }
      
        uint256 bal = address(this).balance;
        uint256 p0 = (bal * 1)/10;
        uint256 p1 = (bal * 5)/10;  
        uint256 p2 = (bal * 4)/10;  
        
        _send(addr0, p0);
        _send(addr1, p1);
        _send(addr2, p2);

    }


    function setBountyPercent(uint256 bountyPercent_) external onlyOwner {
        require(bountyPercent_ < 100);
        bountyPercent = bountyPercent_;
    }

    function withdraw() external onlyOwner {
        (bool s, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }

    receive() external payable {}

    function _send(address recipient, uint256 amount) internal {
        (bool s, ) = payable(recipient).call{value: amount}("");
        require(s);
    }

    function currentBounty() public view returns (uint256) {
        uint256 balance = address(this).balance;
        return ((balance * bountyPercent) / 100);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}