// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Ownable.sol";
interface IERC20 {
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}
contract HoneyBiteCryptoLaunchPad is Ownable{

struct project{
	address acceptPaymentCrypto;
	address cryptoTokenOwner;
	uint cryptoToTokenPrice;				//1*10^18 BNB = 100*10^18 Project Token
	bool status;
} 
mapping(address => project) public LaunchcryptoAsset;
mapping(address => bool) public paymentCrypto;

//1000*10^18 ProjectToken = 1*10^18 BNB
//5000 PT = 1/1000 *5000 = 5 ;; 10000 PT = 1/1000 * 10000 =10 ;; 500 PT = 1/1000 * 500 = 0.5 
function setNewCryptoProject(address _assetContractAddress, address _acceptPaymentCrypto,address _cryptoTokenOwner, uint _cryptoToTokenPrice ) public onlyOwner{
	project memory pt = LaunchcryptoAsset[_assetContractAddress];
	require(!pt.status,"already set. Provide a new Address");
	pt.acceptPaymentCrypto = _acceptPaymentCrypto;
	pt.cryptoTokenOwner = _cryptoTokenOwner;
	pt.cryptoToTokenPrice = _cryptoToTokenPrice;
	pt.status = true;
	LaunchcryptoAsset[_assetContractAddress] = pt;
}

function deleteCryptoProject(address _assetContractAddress) public onlyOwner{
	require(LaunchcryptoAsset[_assetContractAddress].status,"Not registered... Provide another Address");
	delete LaunchcryptoAsset[_assetContractAddress];
}

//1 ProjectToken = 3.25 BNB
//1*10^-18 = 3.25*10^-18

function calculatePrice(uint priceOfToken, uint noOfToken) public pure returns(uint amount){
	amount = priceOfToken * noOfToken;
	amount /= 10**18; 						//1 wei priceOfToken = 3.25*10^-18 ; amount = (3.25*10^-18) * (1*10^-18)
}
function tokenTransferBeforeExchangeUsingTokenCount(address _projectTokenAddress,uint _noOfTokenInWei) public returns(bool transferStatus){
	project memory pt = LaunchcryptoAsset[_projectTokenAddress];
	require(pt.status,"Not registered... Provide another Address");
	address _owner = pt.cryptoTokenOwner;
	address _acceptPaymentCrypto = pt.acceptPaymentCrypto;	
	uint deposit = calculatePrice(pt.cryptoToTokenPrice,_noOfTokenInWei);
	IERC20(_acceptPaymentCrypto).transferFrom(msg.sender, _owner,deposit);
	transferStatus = IERC20(_projectTokenAddress).transferFrom(_owner, msg.sender, _noOfTokenInWei);	
}	
}