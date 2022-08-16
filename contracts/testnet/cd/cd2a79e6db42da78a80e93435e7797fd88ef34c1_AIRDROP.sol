/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: Unlicensed
// Can not be forked - Not open source! 
// Airdrop tool created by GenTokens.com




/*

    ------------
    AIRDROP TOOL
    ------------

    Set the fees on your contract to 0 (if contract has wallet to wallet fee)
    Set this contract address as limit exempt / whitelisted / pre launch access (depending on your contract)
    Calculate how many tokens you need to airdrop and send them to this contract 
    Use the required airdrop function
    Purge any remaining tokens back into your wallet




    We have two airdrop function 
    
    ------------
    Airdrop Dust
    ------------

    If your contract has reflections, the holder values on BSC only update when a person buys or sells. 
    So it will not show their reflections! To update this, you can send them a spec of dust. This is the smallest denomination of your token, and 
    will quickly update all of the holders balances on BSCScan, so you can then use the standard airdrop function to airdrop tokens. 

    To airdrop, send some tokens to this contract, then add your contract address into the field and a list of wallets to airdrop to. 
    Wallets should be comma separated, with no spaces. 

    NOTE - Make sure you remove the following wallets from your list

        The Contract itself
        The Liquidity Pair (uniswapV2pair) address
        PancakeSwap
        The contract address of this airdrop tool
        Any blacklisted wallets

        Also... if you are airdropping people that may already hold your token, if their existing balance and the intended airdrop tokens adds
        up to more than the transaction or holding limit for your token, the entire transaction will fail and be reverted. 


    ----------------
    AIRDROP STANDARD
    ----------------

    (You may need to add more tokenns is you used some to to the dust airdrop!)

    If your contract has reflections, you need to update holders balances before you begin your airdrop. BSCScan only updates when people 
    buy or sell. So use the DUST airdrop function first. Then give BSCScan time to update before exported the updated holder values.

    Ask GEN to grant your wallet access
    Set the fees on your contract to 0 (if contract has wallet to wallet fee)
    Set this contract address as limit exempt / whitelisted / pre launch access (depending on your contract)
    If your contract has reflections, be sure to do the DUST airdrop first!
    If you did a DUST airdrop to update the holder list, download the updated holder values from BSCScan!
    Make sure you send enough tokens to this contract to cover the airdrop
    Enter your token address, number of decimals, and then list of wallet addresses and tokens amounts.
    

    Calculate how many tokens you need to airdrop and send them to this contract 
    Use the required airdrop function
    Purge any remaining tokens back into your wallet
    Let GEN know you're done so he can revoke access

    Airdrop dust first if your token has reflections.

    irst need to send enough tokens to this contract.
    Enter the Contract Address for your token, the number of decimals, and then the list of wallet and tokens. 
    The lists of wallets, and tokens, needs to be comma separated, without spaces.
    These two lists must be the same length. The first wallet in the list will receive the first quantity of tokens





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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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


    mapping (address => uint256) public AccessUntil;


    uint256 BNB_PRICE = 1e17;


    address public fee_Collector = payable(0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0);

    function Pay_1_Day() public payable {
        (bool sent, bytes memory data) = fee_Collector.call{value: BNB_PRICE}("");
        require(sent, "Failed to send BNB");
    }



    function Pay_1_Day_Access() public payable {

        require (msg.value >= BNB_PRICE, "Need to pay 0.1 BNB to use airdrop tool for one day!");
        AccessUntil[msg.sender] = block.timestamp + 1 days;

    }


    // CHECK USER IS OWNER!
    function get_Owner (address Token_CA) internal view returns (address){
        return BEP20(Token_CA).owner();
    }




    // UPDATE REFLECTIONS BY AIRDRIOPPING 1 SPECK OF DUST TO TOKEN HOLDERS
    function Airdrop_Dust(address Token_CA, address[] calldata Wallets) external {

        // One day access
        require(block.timestamp <= AccessUntil[msg.sender], "1 day access expired.");

        // Check msg.sender is owner of the token
        require(get_Owner(Token_CA) == msg.sender, "You must be the token owner to use the airdrop tool!");
        
        // Limit array length to reduce possibiilty of out of gas error
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        for (uint i=0; i < Wallets.length; i++) {
            BEP20(Token_CA).transfer(Wallets[i], 1);
        }
    }



    

    // AIRDROP TOKEN TO HOLDER LIST - ADDS DECIMALS - WHOLE NUMBER OF TOKENS ONLY! 
    function AirDrop_Standard(address Token_CA, uint256 Decimals, address[] calldata Wallets, uint256[] calldata Tokens) external {

        // One day access
        require(block.timestamp <= AccessUntil[msg.sender], "1 day access expired.");

        // Check msg.sender is owner of the token
        require(get_Owner(Token_CA) == msg.sender, "You must be the token owner to use the airdrop tool!");
        
        // Limit array length to avoid out of gas error
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        require(Wallets.length == Tokens.length, "Token and Wallet count missmatch!");

        uint256 checkQuantity;

        for(uint i=0; i < Wallets.length; i++){
        checkQuantity = checkQuantity + Tokens[i];
        }

        require(BEP20(Token_CA).balanceOf(address(this)) >= checkQuantity, "Not Enough Tokens!");

        for (uint i=0; i < Wallets.length; i++) {
            BEP20(Token_CA).transfer(Wallets[i], Tokens[i]*10**Decimals);
        }
    }






    






    // PURGE TOKENS
    function Purge_Tokens(address Token_CA, uint256 Percent) public returns(bool _sent){


        // Check msg.sender is owner of the token
        require(get_Owner(Token_CA) == msg.sender, "You must be the token owner to remove the tokens!");
        

        uint256 totalRandom = BEP20(Token_CA).balanceOf(address(this));
        uint256 removeRandom = totalRandom * Percent / 100;
        _sent = BEP20(Token_CA).transfer(msg.sender, removeRandom);
    }



    // PURGE BNB
    function Purge_BNB(address payable _to) public onlyOwner {
        uint256 BNB = address(this).balance;
        if (BNB > 0) {
        _to.transfer(BNB);
        }
    }


    receive() external payable {}
    
        









        
    }