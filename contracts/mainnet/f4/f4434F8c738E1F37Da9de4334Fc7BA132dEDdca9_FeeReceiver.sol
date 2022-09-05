/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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

interface IOwnedContract {
    function getOwner() external view returns (address);
}

contract FeeReceiver {

    // Token
    address public immutable Token;

    // Recipients Of Fees
    address public addr0 = 0xAA83EA37c8Cf6FC1c4847102efb23d865e722457;
    address public addr1 = 0x0B9FCe86396b3d6B0111b3567f7E7d9DC9C7eD1F;
    address public addr2 = 0xCd0960fdECaD51199346C5d28dA9Ec473fF83f63;
    address public addr3 = 0x4f421429e87196dF186dc35Ec4D35467214d6aa7;

    // Allocation Points
    uint256 public addr0Amt = 8;
    uint256 public addr1Amt = 2;
    uint256 public addr2Amt = 3;
    uint256 public addr3Amt = 5;

    modifier onlyOwner(){
        require(
            msg.sender == IOwnedContract(Token).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    constructor(address Token_) {
        Token = Token_;
    }

    function trigger() external {

        uint balance = IERC20(Token).balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        uint256 denom = addr0Amt + addr1Amt + addr2Amt + addr3Amt;

        uint amt0 = (balance * addr0Amt) / denom;
        uint amt1 = (balance * addr1Amt) / denom;
        uint amt2 = (balance * addr2Amt) / denom;

        if (amt0 > 0) {
            _send(addr0, amt0);
        }
        
        if (amt1 > 0) {
            _send(addr1, amt1);
        }
        
        if (amt2 > 0) {
            _send(addr2, amt2);
        }

        uint bal = IERC20(Token).balanceOf(address(this));
        if (bal > 0){
            _send(addr3, bal);
        }
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function setRecipientAddresses(
        address addr0_,
        address addr1_,
        address addr2_,
        address addr3_
    ) external onlyOwner {
        addr0 = addr0_;
        addr1 = addr1_;
        addr2 = addr2_;
        addr3 = addr3_;
    }

    function setRecipientAllocations(
        uint256 addr0Amt_,
        uint256 addr1Amt_,
        uint256 addr2Amt_,
        uint256 addr3Amt_
    ) external onlyOwner {
        addr0Amt = addr0Amt_;
        addr1Amt = addr1Amt_;
        addr2Amt = addr2Amt_;
        addr3Amt = addr3Amt_;
    }

    receive() external payable {}
    
    function _send(address recipient, uint amount) internal {
        require(
            IERC20(Token).transfer(
                recipient,
                amount
            ),
            'ERR Transfer'
        );
    }
}