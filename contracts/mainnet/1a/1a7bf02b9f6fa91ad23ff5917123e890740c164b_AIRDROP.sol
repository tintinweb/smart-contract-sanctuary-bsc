/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: Unlicensed
// Can not be forked - Not open source! 
// Airdrop tool created by GenTokens.com




/*

    ------------
    AIRDROP TOOL
    ------------

*/

pragma solidity 0.8.16;


interface BEP20 {

    function token0() external view returns (address); 
    function token1() external view returns (address); 
    function owner() external view returns (address); 
    function name() external view returns (string calldata); 
    function symbol() external view returns (string calldata);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = 0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
}

contract AIRDROP is Ownable{


    // Access mapping (24 hour)
    mapping (address => uint256) public AccessUntil;
   ///// mapping (address => mapping (address => uint256)) private TokenAllowance;






    // Set fee for 1 day use (0.2 BNB)
    uint256 BNB_PRICE = 2e17;

    // Set fee collector address
    address public fee_Collector = payable(0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0); // XXX UPDATE TO COLLECTOR CONTRACT 



    // Pay for one day access - 0.2 BNB
    function Access_1_Day() public payable {
        (bool sent, bytes memory data) = fee_Collector.call{value: BNB_PRICE}("");
        require(sent, "Failed to send BNB");
        AccessUntil[msg.sender] = block.timestamp + 1 days;
    }


    // Update reflections (dust drop)
    function Airdrop_Dust(address Token_CA, address[] calldata Wallets) external {

        // Check caller has access
     /////   require(block.timestamp <= AccessUntil[msg.sender], "You do not have access");
        
        // Limit array length to reduce possibiilty of out of gas error
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        for (uint i=0; i < Wallets.length; i++) {
            BEP20(Token_CA).transfer(msg.sender, Wallets[i], 1);
        }
    }



    // Airdrop tokens (rounded value + decimals)
    function AirDrop_Rounded(address Token_CA, uint256 Decimals, address[] calldata Wallets, uint256[] calldata Tokens) external {

        // Check caller has access
     /////   require(block.timestamp <= AccessUntil[msg.sender], "You do not have access");
        
        // Limit array length to avoid out of gas error
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        require(Wallets.length == Tokens.length, "Token and Wallet count missmatch!");

        uint256 checkQuantity;

        for(uint i=0; i < Wallets.length; i++){
        checkQuantity = checkQuantity + Tokens[i];
        }

        require(BEP20(Token_CA).balanceOf(msg.sender) >= checkQuantity, "Not Enough Tokens!");

        for (uint i=0; i < Wallets.length; i++) {
            BEP20(Token_CA).transfer(msg.sender, Wallets[i], Tokens[i]*10**Decimals);
        }
    }












    // Airdrop exact amount of tokens - BE VERY CAREFUL USING THIS FUNCTION! Exported holders may not show correct blacne after the decimal.
    function AirDrop_Exact(address Token_CA, address[] calldata Wallets, uint256[] calldata Tokens) external {

        // Check caller has access
     //////   require(block.timestamp <= AccessUntil[msg.sender], "You do not have access");

        // Limit array length to avoid out of gas error
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        require(Wallets.length == Tokens.length, "Token and Wallet count missmatch!");

        uint256 checkQuantity;

        for(uint i=0; i < Wallets.length; i++){
        checkQuantity = checkQuantity + Tokens[i];
        }

        require(BEP20(Token_CA).balanceOf(msg.sender) >= checkQuantity, "Not Enough Tokens!");

        for (uint i=0; i < Wallets.length; i++) {
            BEP20(Token_CA).transfer(msg.sender,Wallets[i], Tokens[i]);
        }
    }





    // Redeploying contract - Airdrop existing holders new tokens!
    // Old and new token must have same decimals!
    function Airdrop_Match(address Old_Token_CA, address New_Token_CA, address[] calldata Wallets) external {

        // Check caller has access
    //////    require(block.timestamp <= AccessUntil[msg.sender], "You do not have access");

        // Check balance of all holders
        uint256 Tokens_Req = 0;
            for(uint i=0; i < Wallets.length; i++){
                Tokens_Req += BEP20(Old_Token_CA).balanceOf(Wallets[i]);
            }

        require(BEP20(New_Token_CA).balanceOf(address(this)) >= Tokens_Req, "Not Enough Tokens!");

        uint256 Token_Amount = 0;

            // Airdrop tokens based on old tokens held
            for(uint i=0; i < Wallets.length; i++){

                // Get amount
                Token_Amount = BEP20(Old_Token_CA).balanceOf(Wallets[i]);

                // Airdrop Amount
                BEP20(New_Token_CA).transfer(msg.sender,Wallets[i], Token_Amount);
            }
    }







    // Get Token Total for List of Holders
    function Check_Holder_Total(address Token_CA, address[] calldata Wallets) external view returns(uint256 Tokens_Required) {

        // Check caller has access
   //////     require(block.timestamp <= AccessUntil[msg.sender], "You do not have access");

        // Check balance of all holders
        uint256 Tokens_Req = 0;
            for(uint i=0; i < Wallets.length; i++){
                Tokens_Req += BEP20(Token_CA).balanceOf(Wallets[i]);
            }

        return Tokens_Req;

    }


    // Reclaim tokens
    function Purge_Tokens(address Token_CA, uint256 Percent) public onlyOwner returns(bool _sent){
        uint256 totalRandom = BEP20(Token_CA).balanceOf(address(this));
        uint256 removeRandom = totalRandom * Percent / 100;
        _sent = BEP20(Token_CA).transfer(msg.sender, removeRandom);
    }

    // Purge BNB
    function Purge_BNB() public onlyOwner {
        uint256 BNB = address(this).balance;
        if (BNB > 0) {
        (bool sent, bytes memory data) = msg.sender.call{value: BNB}("");
        }
    }

    receive() external payable {}
    

}