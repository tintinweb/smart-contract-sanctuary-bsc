/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract MartianMigrate {

    bool public checkSaleStatus;
    address public oldMartian;
    address public newMartian;

    address public owner;
    uint256 public totalMartianExchanged;

    event MigrateMartain(address token, address to, uint256 amountRecieved);
    // event Whitelist(address indexed userAddress, bool Status);

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(_msgSender() == owner,"TIKI TOKEN: YOU ARE NOT THE OWNER.");
        _;
    }

    constructor( address _oldMartian, address _newMartian) {
        owner =  _msgSender();
        checkSaleStatus = true;
        oldMartian = _oldMartian;
        newMartian = _newMartian;
    }

    function migrateMartian(uint256 _tokenAmount) public {
        // uint256 getV2Cost = _tokenAmount / 10e18 * 10e9;

        
        require(checkSaleStatus == true, "MARTIAN: SALE HAS ENDED.");
        require(_tokenAmount >= 0, "MARTIAN: BUY ATLEAST 1 TOKEN.");
        
        require(IERC20(oldMartian).transferFrom(_msgSender(), address(this), _tokenAmount), "MARTIAN: TRANSFERFROM FAILED!");
        require(IERC20(newMartian).transfer(_msgSender(), _tokenAmount), "MARTIAN: CONTRACT DOES NOT HAVE ENOUGH TOKENS.");

        totalMartianExchanged = totalMartianExchanged + _tokenAmount;
        emit MigrateMartain(newMartian, _msgSender(), _tokenAmount);
    }
    
    // End the sale, don't allow any purchases anymore and send remaining rgp to the owner
    function disableSale() external onlyOwner{

        // End the sale
        checkSaleStatus = false;
        IERC20(newMartian).transfer(owner, IERC20(newMartian).balanceOf(address(this)));
    }

    // To enable the sale, send RGP tokens to this contract
    function enableSale() external onlyOwner{

        // Enable the sale
        checkSaleStatus = true;
    }

    // Withdraw (accidentally) to the contract sent eth
    function withdrawBNB() external payable onlyOwner {
        payable(owner).transfer(payable(address(this)).balance);
    }

    // Withdraw (accidentally) to the contract sent ERC20 tokens
    function withdrawNew(address _token) external onlyOwner {
        uint _tokenBalance = IERC20(_token).balanceOf(address(this));

        IERC20(_token).transfer(owner, _tokenBalance);
    }
}