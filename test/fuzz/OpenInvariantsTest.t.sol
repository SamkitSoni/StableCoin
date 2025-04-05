// SPDX-License-Identifier: MIT

//Have our invariants aka properties

//What are our invariants?

//1. The total supply of the DSC should be less than the total value of collateral
//2. Getter view functions should never revert <- evergreen invariant

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract OpenInvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dscEngine;
    HelperConfig helperConfig;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() public {
        deployer = new DeployDSC();
        (dscEngine, dsc, helperConfig) = deployer.run();
        (,, weth, wbtc,) = helperConfig.activeNetworkConfig();
        // targetContract(address(dscEngine));
        handler = new Handler(dscEngine, dsc);
        targetContract(address(handler));
        //hey, don't call redeemcollateral, unless there is collateral to redeem
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        //get the value of all the collateral in the protocol
        //compare it to all the debt (dsc)
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dscEngine));
        uint256 totalBtcDeposited = IERC20(wbtc).balanceOf(address(dscEngine));
        uint256 wethValue = dscEngine.getUSDValue(weth, totalWethDeposited);
        uint256 wbtcValue = dscEngine.getUSDValue(wbtc, totalBtcDeposited);
        assert((wethValue + wbtcValue) >= totalSupply);
    }

    // function invariant_getterShouldntRevert() public view {
    //     //get the value of all the collateral in the protocol
    //     //compare it to all the debt (dsc)
    //     address[] memory collateralTokens = dscEngine.getCollateralTokens();
    //         dscEngine.getCollateralValue(collateralTokens[i]);
    //         dscEngine.getAccountInformation(msg.sender);
    //         dscEngine.getCollateralTokens();
    //         dscEngine.getTokenAmountFromUsd(collateralTokens[i], 1 ether);
    //         dscEngine.getUSDValue(collateralTokens[i], 1 ether);
    // }
}
