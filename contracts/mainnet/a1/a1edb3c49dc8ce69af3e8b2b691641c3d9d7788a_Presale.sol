/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;
pragma experimental ABIEncoderV2;
interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/* --------- Access Control --------- */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Claimable is Ownable {
    function claimToken(address tokenAddress, uint256 amount)
        external
        onlyOwner
    {
        IERC20(tokenAddress).transfer(owner(), amount);
    }

    function claimETH(uint256 amount) external onlyOwner {
        (bool sent, ) = owner().call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function WithdrawBalance() public payable onlyOwner {
        
        // withdraw all ETH
        (bool sent, ) = msg.sender.call{ value: address(this).balance }("");
        require(sent, "Failed to send Ether");
    }

    
}

contract Presale is Claimable {
    event Buy(address to, uint256 amount);
    struct Terms {
        uint256 firstPrice; //1e6
        uint256 firstPeriod;
        uint256 secondPrice; //1e6
        uint256 secondPeriod;
        uint256 price; //1e6
    }

    uint256 private totalPresaleAmount;
    Terms public terms;
    address public tokenAddress;
    address adminWallet;

    uint256 public startTime;

    constructor(
        address _tokenAddress,
        address _adminWallet,
        Terms memory _terms
    ) {
        tokenAddress = _tokenAddress;
        adminWallet = _adminWallet;
        terms = _terms;
        startTime = block.timestamp;
    }

    function resetTerms(Terms memory _terms) public onlyOwner {
        terms = _terms;
    }
    function resetStartTime() public onlyOwner {
        startTime = block.timestamp;
    }

    function setAdminWallet(address _adminWallet) external onlyOwner {
        adminWallet = _adminWallet;
    }

    function buy() public payable {
        uint256 tokenAmount = (msg.value * getPrice()) / 1e6;
        totalPresaleAmount = tokenAmount;
        uint256 currentStage = getStage();
        bool checkMaxcos = currentStage * 60000000 > tokenAmount;
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        require(checkMaxcos, "Current stage presale was finished.");
        (bool sent, ) = owner().call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        emit Buy(msg.sender, tokenAmount);
    }

    function getPrice() public view returns (uint256 tokenPrice) {
        if(block.timestamp > terms.firstPeriod){
            tokenPrice = terms.firstPrice;
        } else if(block.timestamp > terms.secondPeriod){
            tokenPrice = terms.secondPrice;
        } else{
            tokenPrice = terms.price;
        }
    }

    function getStage() public view returns (uint256 stageNo) {
        if(block.timestamp > terms.firstPeriod){
            stageNo = 1;
        } else if(block.timestamp > terms.secondPeriod){
            stageNo = 2;
        } else{
            stageNo = 3;
        }
    }

    receive() external payable {
        buy();
    }

    fallback() external payable {
        buy();
    }
}