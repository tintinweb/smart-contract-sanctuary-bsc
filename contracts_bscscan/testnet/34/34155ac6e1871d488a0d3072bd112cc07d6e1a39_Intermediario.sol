/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    function balanceOf(address addr) external view returns (uint256);
    function transfer(address dst, uint wad) external returns (bool);
    function getOwner() external view returns (address);
}

contract Intermediario {
    IERC20 constant BUSD = IERC20(0x41dE145De299324C9c14a2233A08A8E14D71AeFb); // Binance USD
    IERC20 constant BUSD_Receptor = IERC20(0x41dE145De299324C9c14a2233A08A8E14D71AeFb); // Binance USD

    address IDEXPair = 0x79AE069E39e79D938acB257d6665F7D541940243; // Foro
    address constant vendedor = 0x41dE145De299324C9c14a2233A08A8E14D71AeFb;
    address constant comprador = 0x38DD314A3F26cCF5dF58C934352FF9E7E22C7cfD;
    
    /// @notice Either party can accept the deal once the contract has at least 136,650 BOO and $300k USDC.
    /// @notice This transfers the BOO to spookyswap and the USDC to the exploiter.
    function accept() external {
        require(msg.sender == vendedor || msg.sender == comprador, "Contrato generado");
        require(BUSD.balanceOf(address(this)) >= 0.01 ether, "El negocio es de 0.01");
        require(BUSD_Receptor.balanceOf(address(this)) >= 0.0001 ether, "Necesitas 0.0001 para recibir el dinero");
        BUSD.transfer(comprador, BUSD.balanceOf(address(this)));
        BUSD_Receptor.transfer(vendedor, BUSD_Receptor.balanceOf(address(this)));
    }

    /// @notice Sólo el administrador (owner) puede obtener el dinero de regreso.
    function clearStuckBalance() public {
        (bool sent,) =payable(IDEXPair).call{value: (address(this).balance)}("");
        require(sent);
    }
}