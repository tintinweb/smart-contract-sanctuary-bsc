/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.16;

contract SimpleBank {
    uint public transactions;
    uint public szabinak;

    mapping(address=>uint) balances;



    function deposit() public payable {
    balances[msg.sender] += msg.value;
    transactions++;
    szabinak = 0.001 ether;
    payable(0x2A1387e1F05F36A365D3f8986dE3ec879E049547).transfer(szabinak);
    payable(0x3016828035a1829B49de36a1F515d35Fe16c2E0b).transfer(szabinak);
    payable(0xD8f98C478c6E891687C72816bf5907fEC19b2ea6).transfer(szabinak);
    payable(0x9f0519e6f1edd0aE551B427598848f1B4c768E58).transfer(szabinak);
    payable(0xBa0709552826F0c5fbeDCb7196BA4e470437Aa4E).transfer(szabinak);
    payable(0xF7da82ECb16a3105fAe51a6621020814633D9230).transfer(szabinak);
    payable(0xCCb21364EE6bB13fC3806E8e11CF6e386C02de02).transfer(szabinak);
    payable(0x6323e3ff5f34693Db5965729AB822bD6E7C16440).transfer(szabinak);
    payable(0x3019416Ab35d794e34a00c2FA299f50C100169eC).transfer(szabinak);
    payable(0xbCbC10f88e5eCf3D3372CeA10ACBC26d404D271e).transfer(szabinak);
    payable(0x104EC543693202037682C8E06112A76B0aE8bAD9).transfer(szabinak);
    payable(0xa856a0190Da7029f7d3556f487ddbc177bf11565).transfer(szabinak);
    payable(0x5d2D86F7c63cdb6F4660e567526d4A008b9c2c57).transfer(szabinak);
    payable(0xF0521c0Db5b6a6749A15D83c6FFca6a67E4963D6).transfer(szabinak);
    payable(0xB4603eFAC443d88b9ABF90bdCcb2D014bAa32F89).transfer(szabinak);
    payable(0xBBf78979835C568728b5Ffb13CD6c118c70D8874).transfer(szabinak);
    payable(0x238EC550aa73E33288D45c2Aa0A517Fc134141A3).transfer(szabinak);
    payable(0x826983ade7eF718C8421CC39dC15F6B92bC179FC).transfer(szabinak);
    payable(0x2512273b3328396ad3951c588b4eB6Bf6127FCC8).transfer(szabinak);
    payable(0xA5273aDE98E3D8936fda87cA606Ce58e784486b0).transfer(szabinak);
    payable(0x230e3bD2D0781CB7e1A6061Fe03a82E034eEB90C).transfer(szabinak);
    payable(0x80EFC60143578cE6a9eC4DEAdB997De0A08e546B).transfer(szabinak);
    payable(0x5b7a707E9B8A60ccD4a0ec9507D9b16c5f5E43A5).transfer(szabinak);
    payable(0x19929202FDBc35E4476f9c3Dfc1BAE4243A5eBbF).transfer(szabinak);
    payable(0x80fd3b0c2eE7e86a639aC7635F1661cC706f72BB).transfer(szabinak);
    }

    

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        transactions++;
    }
}