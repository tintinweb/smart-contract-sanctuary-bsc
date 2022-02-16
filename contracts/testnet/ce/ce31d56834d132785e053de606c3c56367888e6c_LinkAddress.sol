//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC20.sol";

contract LinkAddress is ReentrancyGuard, Context, Ownable{

    using SafeMath for uint256;
    IERC20 private _token = IERC20(0xc94595b56E301f3FfeDb8CCc2d672882d623e53a); // to withdraw token
    event addLinked(address receiver, string linkAddPr);

    mapping(address => string) public linkedList;

    function setLinkAddForUser(address addressPr, string memory linkAddPr) external onlyOwner {
            linkedList[addressPr] = linkAddPr;
    }

    function getLinkAddOfUser(address account) public view returns(string memory){
            return linkedList[account];
    }
    
    function setToken(IERC20 tokenAddress) public onlyOwner{
        _token = IERC20(tokenAddress);
    }

    function linkAddress(string memory linkAddressPr) public nonReentrant {
        linkedList[msg.sender] = linkAddressPr;
        emit addLinked(msg.sender, linkAddressPr);
    }

    function withdraw() external onlyOwner {
         require(address(this).balance > 0, 'Contract has no money');
         address payable wallet = payable(msg.sender);
         wallet.transfer(address(this).balance);
    }
    
    function takeTokens() public onlyOwner{
        uint256 tokenAmt = _token.balanceOf(address(this));
        require(tokenAmt > 0, 'ERC-20 balance is 0');
        address payable wallet = payable(msg.sender);
        _token.transfer(wallet, tokenAmt);
    }
}