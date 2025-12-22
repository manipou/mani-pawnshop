<script lang="ts">
	import { visibilityStore as visibility, ShopIndex, PawnData, Muted, Config } from "$lib/stores/VisibilityStore";
	import { fetchNui } from "$lib/utils/fetchNui";
	import { onMount } from 'svelte';
	
	// Import assets
	import screenBg from '../assets/screen.png';
	import clickSound from '../assets/sounds/click.mp3';
	import closeSound from '../assets/sounds/close.mp3';
	import openSound from '../assets/sounds/open.mp3';
	let isOpen = false;
	let isShuttingDown = false;
	let currentTime = '';
	let currentDate = '';
	let activeTab = 'contracts';

	function TurnOff(HideUI: boolean = false) {
		PlaySound("close", 0.1);
		isShuttingDown = true;
		setTimeout(() => {
			visibility.hide();
			isShuttingDown = false;
			if (HideUI) {
				fetchNui("hideUI");
			}
		}, 2000);
	}

	function PlaySound(Sound: string, Volume: number) {
		if ($Muted) return;
		const soundMap: { [key: string]: string } = {
			click: clickSound,
			close: closeSound,
			open: openSound
		};
		const audio = new Audio(soundMap[Sound]);
		audio.volume = Volume;
		audio.play();
	}

	function toggleMute() {
		$Muted = !$Muted;
		fetchNui('SetMute', $Muted);
		PlaySound("click", 0.2);
	}
	
	const Contracts = [
		{ Id: 1, MinLevel: 1, Name: 'Skralde Jagt', Difficulty: 'Let', Desc: 'Led efter materialer i skraldespande.', Img: 'https://media.discordapp.net/attachments/1345921483695984753/1451494951975391333/image.png?ex=69466184&is=69451004&hm=89ecdd3861b6ad9b4c3100362de0addc945be687d06a1a75ed09fa592776ba85&=&format=webp&quality=lossless', Disabled: false },
		{ Id: 2, MinLevel: 2, Name: 'Skråt køretøjer', Difficulty: 'Normal', Desc: 'Skråt specifikke køretøjer for materialer.', Img: 'https://static.wikia.nocookie.net/gtawiki/images/c/c2/Trash-O_Dumpster_%28GTA_SA%29.jpg/revision/latest?cb=20100327102732', Disabled: true },
		{ Id: 3, MinLevel: 3, Name: 'Kommer senere', Difficulty: 'Svær', Desc: 'Kommer senere', Img: 'https://static.wikia.nocookie.net/gtawiki/images/c/c2/Trash-O_Dumpster_%28GTA_SA%29.jpg/revision/latest?cb=20100327102732', Disabled: true }
	];

	const Tabs = [
		{ Id: 'contracts', Label: 'Kontrakter', BossOnly: false },
		{ Id: 'orders', Label: 'Ordrer', BossOnly: false },
		{ Id: 'pay', Label: 'Lønning', BossOnly: true },
	];

	interface Order {
		Label: string;
		Id: number;
		InterestedIn: Array<{ Item: string; Amount: number }>;
		CreatedAt: number;
		Logo: string;
		Items: number;
		Coords: { x: number; y: number; z: number; w: number };
	}

	let Orders: Order[] = [];
	let employeePayPercentages: { [key: string]: number } = {};

	function formatTimeRemaining(createdAt: number): string {
		const expireMinutes = $Config?.Orders?.Expire || 120;
		const now = Math.floor(Date.now() / 1000);
		const expiresAt = createdAt + (expireMinutes * 60);
		const remaining = expiresAt - now;
		
		if (remaining <= 0) {
			return 'Udløbet';
		}
		
		const hours = Math.floor(remaining / 3600);
		const minutes = Math.floor((remaining % 3600) / 60);
		
		if (hours > 0) {
			return `${hours}t ${minutes}m tilbage`;
		}
		return `${minutes}m tilbage`;
	}
	
	function selectContract(Data : any) {
		PlaySound("click", 0.2);
		TurnOff();
		fetchNui('StartContract', Data);
	}

	function acceptOrder(Order : any) {
		PlaySound("click", 0.2);
		TurnOff();
		fetchNui('AcceptOrder', Order.Id);
	}

	function SelectTab(TabId: string) {
		activeTab = TabId;
		if (TabId === 'orders') {
			fetchNui('FetchOrders').then((FetchedOrders: any) => {
				Orders = FetchedOrders;
			});
		} else if (TabId === 'pay') {
			// Initialize percentages for each employee if not set
			if ($PawnData.Employees) {
				Object.keys($PawnData.Employees).forEach(id => {
					if (!employeePayPercentages[id]) {
						employeePayPercentages[id] = 50; // Default 50%
					}
				});
			}
		}
	}

	function printCheck(employee: any) {
		PlaySound("click", 0.2);
		const percentage = employeePayPercentages[employee.Identifier] || 50;
		fetchNui('PrintCheck', {
			Identifier: employee.Identifier,
			Percentage: percentage,
		}).then((NewEmployees: any) => {
			if (NewEmployees) {
				PawnData.update(data => {
					return { ...data, Employees: NewEmployees };
				});
			}
		});
	}

	function updateTime() {
		const now = new Date();
		currentTime = now.toLocaleTimeString('da-DK', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
		currentDate = now.toLocaleDateString('da-DK', { month: '2-digit', day: '2-digit', year: 'numeric' });
	}

	onMount(() => {
		PlaySound("open", 0.1);

		updateTime();
		const timeInterval = setInterval(updateTime, 1000);

		const timer = setTimeout(() => {
			isOpen = true;
		}, 1000);

		const keyHandler = (e: KeyboardEvent) => {
			if ($visibility && e.code === "Escape") {
				TurnOff(true);
			}
		};

		window.addEventListener("keydown", keyHandler);
		return () => {
			clearTimeout(timer);
			clearInterval(timeInterval);
			window.removeEventListener("keydown", keyHandler)
		};
	});
</script>

<style>
	@keyframes slideIn {
		from {
			opacity: 0;
			transform: scale(0.7);
		}
		to {
			opacity: 1;
			transform: scale(1);
		}
	}

	.window-open {
		animation: slideIn 0.6s ease-out forwards;
	}

	.xp-button:active {
		background: linear-gradient(135deg, #bfb9b1 0%, #ece9d8 100%) !important;
		box-shadow: inset 1px 1px #808080, inset -1px -1px #ffffff !important;
		transform: translateY(1px);
	}

	@keyframes windowClose {
		0% {
			opacity: 1;
			transform: scale(1);
		}
		100% {
			opacity: 0;
			transform: scale(0.8);
		}
	}

	@keyframes monitorOff {
		0% {
			background-color: transparent;
		}
		100% {
			background-color: black;
		}
	}

	@keyframes screenFadeOut {
		0% {
			opacity: 1;
		}
		100% {
			opacity: 0;
		}
	}

	.window-closing {
		animation: windowClose 0.5s ease-out forwards;
	}

	.monitor-turning-off::before {
		content: '';
		position: absolute;
		inset: 0;
		background-color: black;
		opacity: 0;
		animation: fadeToBlack 0.8s ease-in-out forwards;
		animation-delay: 0.5s;
		pointer-events: none;
		z-index: 9999;
	}

	@keyframes fadeToBlack {
		0% {
			opacity: 0;
		}
		100% {
			opacity: 1;
		}
	}

	.screen-fading {
		animation: screenFadeOut 0.7s ease-out forwards;
		animation-delay: 1.3s;
	}

	/* Retro XP-style slider */
	input[type="range"] {
		-webkit-appearance: none;
		width: 100%;
		height: 18px;
		background: transparent;
		cursor: pointer;
	}

	input[type="range"]::-webkit-slider-track {
		background: transparent;
		height: 4px;
	}

	input[type="range"]::-webkit-slider-thumb {
		-webkit-appearance: none;
		width: 12px;
		height: 18px;
		background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%);
		border: 1px solid #808080;
		box-shadow: inset 1px 1px #ffffff, inset -1px -1px #606060;
		cursor: pointer;
		margin-top: 0px;
	}

	input[type="range"]::-moz-range-track {
		background: transparent;
		height: 4px;
	}

	input[type="range"]::-moz-range-thumb {
		width: 12px;
		height: 18px;
		background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%);
		border: 1px solid #808080;
		box-shadow: inset 1px 1px #ffffff, inset -1px -1px #606060;
		cursor: pointer;
		border-radius: 0;
	}
</style>

<!-- Background with screen image -->
<div class="w-full h-screen flex items-center justify-center {isShuttingDown ? 'screen-fading' : ''}">
	<!-- Monitor Bezel/Frame -->
	<div style="padding: 35px; background: linear-gradient(to bottom, #c8c8c8 0%, #a8a8a8 50%, #888888 100%); border-radius: 4px; box-shadow: 0 8px 30px rgba(0,0,0,0.5), inset 0 2px 3px rgba(255,255,255,0.4), inset 0 -2px 3px rgba(0,0,0,0.3); border: 2px solid #707070;">
		<div 
			class="flex items-center justify-center relative {isShuttingDown ? 'monitor-turning-off' : ''}"
			style="width: 1632px; height: 918px; background-image: url({screenBg}); background-size: cover; background-position: center; box-shadow: inset 0 0 20px rgba(0,0,0,0.6);"
		>
		<!-- Company Logo -->
		{#if $Config?.Shops?.[$ShopIndex - 1]?.Logo}
			<div class="absolute inset-0 flex items-center justify-center pointer-events-none">
				<img 
					src={$Config.Shops[$ShopIndex - 1].Logo} 
					alt="Company Logo"
					style="max-width: 653px; max-height: 367px; opacity: 0.85;"
					class="object-contain"
				/>
			</div>
		{/if}
		
		<!-- Time and Date Display -->
		<div class="absolute flex items-center gap-4" style="bottom: 5px; right: 12px;">
			<!-- Mute Button (Retro Win95 Style) -->
			<button 
				on:click={toggleMute}
				class="xp-button flex items-center justify-center"
				style="width: 22px; height: 22px; background: #c0c0c0; border-top: 1px solid #ffffff; border-left: 1px solid #ffffff; border-right: 1px solid #000000; border-bottom: 1px solid #000000; box-shadow: inset 1px 1px 0 #dfdfdf, inset -1px -1px 0 #808080;"
				title={$Muted ? 'Unmute' : 'Mute'}
			>
				<svg 
					xmlns="http://www.w3.org/2000/svg" 
					width="11" 
					height="11" 
					viewBox="0 0 24 24" 
					fill="none" 
					stroke="#000000" 
					stroke-width="2.5" 
					stroke-linecap="square" 
					stroke-linejoin="miter"
				>
					{#if $Muted}
						<!-- Muted Icon -->
						<path d="M11 5L6 9H2v6h4l5 4V5z"/>
						<line x1="23" y1="9" x2="17" y2="15"/>
						<line x1="17" y1="9" x2="23" y2="15"/>
					{:else}
						<!-- Unmuted Icon -->
						<path d="M11 5L6 9H2v6h4l5 4V5z"/>
						<path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"/>
					{/if}
				</svg>
			</button>
			
			<div class="text-white text-right" style="text-shadow: 0.5px 0.5px 1px rgba(0,0,0,0.6);">
				<div class="font-semibold" style="font-size: 13px;">{currentTime}</div>
				<div style="font-size: 11px;">{currentDate}</div>
			</div>
		</div>
		
		<!-- Taskbar with Program Icon -->
		{#if $Config?.Shops?.[$ShopIndex - 1]?.Logo}
			<div class="absolute flex items-center gap-1 px-2 py-1 rounded" style="bottom: 5px; left: 147px; background: linear-gradient(135deg, #6ba3d8 0%, #4a8ec9 100%); border: 1px solid rgba(255,255,255,0.4); box-shadow: 0 2px 4px rgba(0,0,0,0.2);">
				<img 
					src={$Config.Shops[$ShopIndex - 1].Logo}
					alt="Program Icon"
					class="object-contain"
					style="width: 21px; height: 21px;"
				/>
				<span class="text-white font-semibold" style="font-size: 13px;">Pawnshop</span>
			</div>
		{/if}
		
		<!-- Empty program window -->
		<div class="shadow-2xl {isOpen ? 'window-open' : ''} {isShuttingDown ? 'window-closing' : ''}" style="width: 979px; height: 643px; border: 2px solid #dfdfdf; background: #ece9d8; display: flex; flex-direction: column; {!isOpen ? 'opacity: 0;' : ''}">
			<!-- Title bar (XP Style) -->
			<div class="px-2 py-1 flex justify-between items-center flex-shrink-0" style="background: linear-gradient(to right, #0a246a, #1084d7); border-bottom: 2px solid #dfdfdf;">
				<div class="flex items-center gap-2 flex-1">
					<span class="text-white text-xs font-bold">Pantelåner System</span>
				</div>
				<div class="flex gap-1">
					<!-- Minimize button -->
					<button class="w-6 h-5 flex items-center justify-center text-gray-800 text-xs font-bold rounded" style="background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%); border: 1px solid #dfdfdf; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080;">
						_
					</button>
					<!-- Maximize button -->
					<button class="w-6 h-5 flex items-center justify-center text-gray-800 text-xs font-bold rounded" style="background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%); border: 1px solid #dfdfdf; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080;">
						□
					</button>
					<!-- Close button -->
					<button class="w-6 h-5 flex items-center justify-center text-gray-800 text-xs font-bold rounded" style="background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%); border: 1px solid #dfdfdf; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080;">
						×
					</button>
				</div>
			</div>

			<!-- Content area -->
			<div class="flex-grow overflow-hidden" style="background: #ffffff; border-top: 1px solid #dfdfdf; display: flex;">
				<!-- Vertical Tabs on Left -->
				<div class="flex flex-col" style="width: 100px; background: #ece9d8; border-right: 1px solid #808080;">
					{#each Tabs as Tab}
						{#if !Tab.BossOnly || $PawnData.IsBoss}
							<button 
								class="py-3 px-2 text-xs font-semibold border-b" 
								style="{activeTab === Tab.Id ? 'background: #ffffff; border-left: 3px solid #0a246a; color: #0a246a;' : 'background: #ffffff; color: #808080; border-left: 3px solid transparent;'} border-bottom: 1px solid #808080;"
								on:click={() => { 
									PlaySound("click", 0.2);
									SelectTab(Tab.Id);
								}}
							>
								{Tab.Label}
							</button>
						{/if}
					{/each}
				</div>

				<!-- Tab Content -->
				<div class="flex-grow overflow-auto p-3">
					{#if activeTab === 'contracts'}
						<!-- Level and XP Display -->
						<div class="mb-3 p-2 rounded" style="background: #f0f0f0; border: 1px solid #d4d0c8;">
							<div class="flex justify-between items-center mb-1">
								<span class="text-sm font-bold" style="color: #0a246a;">Level: {$PawnData.Level}</span>
								<span class="text-xs" style="color: #666;">{$PawnData.XP} / {$PawnData.IsMaxLevel ? "Maks" : $PawnData.MaxXP} XP</span>
							</div>
							<div class="w-full h-4 rounded" style="background: #d4d0c8; border: 1px solid #808080;">
								<div 
									class="h-full rounded" 
									style="width: {$PawnData.IsMaxLevel ? 100 : ($PawnData.XP / $PawnData.MaxXP) * 100}%; background: linear-gradient(to right, #1084d7, #0a246a);"
								></div>
							</div>
						</div>
						
						<!-- Contracts Grid -->
						<div class="grid grid-cols-3 gap-3">
							{#each Contracts as Contract}
								<div
									class="flex flex-col rounded overflow-hidden"
									style="background: #ffffff; border: 2px solid #d4d0c8; box-shadow: 2px 2px 4px rgba(0,0,0,0.1); {Contract.Disabled ? 'filter: grayscale(100%); opacity: 0.7;' : ''}"
								>
									<!-- Contract Image -->
									<div class="relative" style="height: 150px; background: #f0f0f0;">
										<img 
											src={Contract.Img} 
											alt={Contract.Name}
											class="w-full h-full object-cover"
											style="{Contract.Disabled ? 'filter: grayscale(100%);' : ''}"
										/>
									{#if Contract.Disabled}
										<div class="absolute inset-0 flex items-center justify-center" style="background: rgba(0,0,0,0.4);">
											<span class="text-white font-bold text-sm" style="text-shadow: 0 2px 4px rgba(0,0,0,0.8);">DEAKTIVERET</span>
										</div>
									{/if}
										<!-- Difficulty Badge (XP Style) -->
										<span 
											class="absolute top-2 right-2 text-[10px] px-2 py-1 font-bold" 
											style="background: linear-gradient(135deg, {Contract.Difficulty === 'Let' ? '#e8f5e8' : Contract.Difficulty === 'Normal' ? '#fff9e6' : '#ffe8e8'} 0%, {Contract.Difficulty === 'Let' ? '#d4e8d4' : Contract.Difficulty === 'Normal' ? '#f5ecc8' : '#f5d4d4'} 100%); color: #000000; border: 1px solid {Contract.Difficulty === 'Let' ? '#b8d4b8' : Contract.Difficulty === 'Normal' ? '#d4c490' : '#d4b0b0'}; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080, 1px 1px 2px rgba(0,0,0,0.3);"
										>
											{Contract.Difficulty}
										</span>
									<!-- Min Level Badge -->
									<span 
										class="absolute top-2 left-2 text-[10px] px-2 py-1 font-bold" 
										style="background: linear-gradient(135deg, {$PawnData.Level >= Contract.MinLevel ? '#e8f5ff' : '#f0f0f0'} 0%, {$PawnData.Level >= Contract.MinLevel ? '#d4e8f5' : '#d4d4d4'} 100%); color: {$PawnData.Level >= Contract.MinLevel ? '#0a246a' : '#808080'}; border: 1px solid {$PawnData.Level >= Contract.MinLevel ? '#b8d4e8' : '#a0a0a0'}; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080, 1px 1px 2px rgba(0,0,0,0.3);"
									>
										Lvl {Contract.MinLevel}
									</span>
								</div>
								
								<!-- Contract Info -->
							<div class="p-2 flex flex-col">
								<div class="flex justify-between items-center mb-1">
									<div class="text-xs font-bold" style="color: #0a246a;">{Contract.Name}</div>
									{#if $PawnData.Level < Contract.MinLevel}
										<div class="text-[9px] text-red-600 font-semibold">Kræver Level {Contract.MinLevel}</div>
									{/if}
								</div>
								<div class="text-[10px] mb-1" style="color: #666; line-height: 1.3;">{Contract.Desc}</div>
								
								<!-- Start Button -->
								<div class="flex">
									<button 
										class="xp-button px-3 py-1 text-[10px] font-bold rounded ml-auto" 
										style="background: linear-gradient(135deg, {$PawnData.Level >= Contract.MinLevel && !Contract.Disabled ? '#ece9d8' : '#d4d0c8'} 0%, {$PawnData.Level >= Contract.MinLevel && !Contract.Disabled ? '#bfb9b1' : '#a0a0a0'} 100%); border: 1px solid #dfdfdf; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080; transition: all 0.05s ease; {$PawnData.Level < Contract.MinLevel || Contract.Disabled ? 'opacity: 0.5; cursor: not-allowed;' : ''}"
										on:click={() => $PawnData.Level >= Contract.MinLevel && !Contract.Disabled && selectContract(Contract)}
										disabled={$PawnData.Level < Contract.MinLevel || Contract.Disabled}
									>
										Start
									</button>
								</div>
							</div>
								</div>
							{/each}
						</div>
					
					{:else if activeTab === 'orders'}
						<!-- Orders Content -->
						<div class="mb-3 flex justify-between items-center">
							<div>
								<h2 class="text-sm font-bold mb-1" style="color: #0a246a;">Materiale Forespørgsler</h2>
								<p class="text-xs" style="color: #666;">Virksomheder der ønsker at købe materialer fra pantelåneren.</p>
							</div>
							<!-- Refresh Button -->
							<button 
								class="xp-button flex items-center gap-1 px-3 py-1.5 text-xs font-bold rounded" 
								style="background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%); border: 1px solid #dfdfdf; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080; transition: all 0.05s ease;"
								on:click={() => {
									PlaySound("click", 0.2);
									fetchNui('FetchOrders').then((FetchedOrders: any) => {
										Orders = FetchedOrders;
									});
								}}
							>
								<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
									<path d="M21.5 2v6h-6M2.5 22v-6h6M2 11.5a10 10 0 0 1 18.8-4.3M22 12.5a10 10 0 0 1-18.8 4.2"/>
								</svg>
								Opdater
							</button>
						</div>
						{#if !Array.isArray(Orders) || Orders.filter(o => o && o.Available !== false && o.Id && o.Label).length === 0}
							<div class="flex items-center justify-center h-64">
								<div class="text-center">
									<p class="text-sm font-semibold mb-1" style="color: #0a246a;">Ingen aktive ordrer</p>
									<p class="text-xs" style="color: #666;">Der er ingen tilgængelige ordrer i øjeblikket</p>
								</div>
							</div>
						{:else}
							<!-- Orders Grid -->
							<div class="grid grid-cols-2 gap-3">
							{#each (Array.isArray(Orders) ? Orders : []).filter(o => o && o.Available !== false && o.Id && o.Label) as Order}
									<div
										class="flex flex-col rounded overflow-hidden"
										style="background: #ffffff; border: 2px solid #d4d0c8; box-shadow: 2px 2px 4px rgba(0,0,0,0.1);"
									>
										<!-- Company Header -->
										<div class="p-3 flex items-center gap-3" style="background: #f0f0f0; border-bottom: 1px solid #d4d0c8;">
											<img src="{Order.Logo}" alt="{Order.Label}" class="rounded" style="width: 50px; height: 50px; border: 1px solid #d4d0c8; object-fit: contain;" />
											<div class="flex-grow">
												<div class="text-sm font-bold mb-1" style="color: #0a246a;">{Order.Label}</div>
												<div class="text-[10px]" style="color: #666;">Forespørgsel #{Order.Id}</div>
											</div>
										<div class="text-[11px]" style="color: #333;">{formatTimeRemaining(Order.CreatedAt)}</div>
									</div>

									<!-- Order Details -->
									<div class="p-3 flex-grow">
										<div class="mb-3">
											<div class="text-xs font-semibold mb-2" style="color: #0a246a;">Ønskede Materialer ({Order.Items} {Order.Items === 1 ? 'type' : 'typer'})</div>
											<div class="space-y-1">
												{#each Order.InterestedIn as item}
													<div class="flex items-center justify-between p-2 rounded" style="background: #f0f0f0; border: 1px solid #d4d0c8;">
														<span class="text-xs font-semibold" style="color: #1084d7;">{item.Item}</span>
														<span class="text-xs" style="color: #666;">{item.Amount}x</span>
													</div>
												{/each}
											</div>
										</div>
									</div>

								<!-- Accept Button -->
								<div class="p-3 pt-0">
									<button 
										class="xp-button w-full px-3 py-2 text-xs font-bold rounded" 
										style="background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%); border: 1px solid #dfdfdf; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080; transition: all 0.05s ease"
										on:click={() => acceptOrder(Order)}
									>
										Acceptér Ordre
									</button>
								</div>
							</div>
						{/each}
							</div>
						{/if}
					{:else if activeTab === 'pay'}
						<!-- Pay Tab Content -->
						<div class="mb-3">
							<h2 class="text-sm font-bold mb-1" style="color: #0a246a;">Medarbejderlønninger</h2>
							<p class="text-xs" style="color: #666;">Oversigt over alle medarbejdere og deres indtjening.</p>
						</div>

						{#if $PawnData.Employees && Object.keys($PawnData.Employees).length > 0}
							<!-- Employees Grid -->
							<div class="grid grid-cols-2 gap-3">
								{#each Object.values($PawnData.Employees).sort((a, b) => (b.Profit || 0) - (a.Profit || 0)) as Employee}
									<div
										class="rounded flex flex-col"
										style="background: #ffffff; border: 2px solid #d4d0c8; box-shadow: 2px 2px 4px rgba(0,0,0,0.1);"
									>
										<!-- Employee Header -->
										<div class="p-3" style="background: #f0f0f0; border-bottom: 1px solid #d4d0c8;">
											<div class="text-sm font-bold mb-1" style="color: #0a246a;">{Employee.Name || 'Ukendt'}</div>
											<div class="flex items-center justify-between text-xs" style="color: #666;">
												<span>Profit: <span class="font-bold" style="color: #0a246a;">{Employee.Profit?.toLocaleString() || 0} kr.</span></span>
												<span>Raffineret: <span class="font-bold" style="color: #0a246a;">{Employee.Refined || 0}</span></span>
											</div>
										</div>

										<div class="p-3 flex-grow flex flex-col">
											{#if (Employee.Profit || 0) > 0}
												<!-- Pay Controls -->
												<div class="flex-grow flex flex-col justify-between">
													<div class="mb-3">
														<div class="flex items-center justify-between mb-2">
															<span class="text-xs font-semibold" style="color: #1084d7;">Udbetaling:</span>
															<span class="text-xs font-bold" style="color: #0a246a;">{Math.floor(((Employee.Profit || 0) * (employeePayPercentages[Employee.Identifier] || 50)) / 100).toLocaleString()} kr.</span>
														</div>
														<!-- Slider -->
														<div class="mb-2 flex items-center" style="background: #d4d0c8; padding: 1px 4px; border: 1px solid #808080; box-shadow: inset 1px 1px 2px rgba(0,0,0,0.3); height: 6px;">
															<input 
																type="range" 
																min="1" 
																max="100" 
																bind:value={employeePayPercentages[Employee.Identifier]}
																class="w-full"
															/>
														</div>
														<div class="flex justify-between text-[10px]" style="color: #808080;">
															<span>1%</span>
															<span class="font-bold" style="color: #0a246a;">{employeePayPercentages[Employee.Identifier] || 50}%</span>
															<span>100%</span>
														</div>
													</div>
													<button 
														class="xp-button w-full px-3 py-2 text-xs font-bold rounded" 
														style="background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%); border: 1px solid #dfdfdf; box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080; transition: all 0.05s ease;"
														on:click={() => printCheck(Employee)}
													>
														Print Check
													</button>
												</div>
											{:else}
												<div class="flex items-center justify-center flex-grow">
													<span class="text-xs" style="color: #808080;">Ingen profit</span>
												</div>
											{/if}
										</div>
									</div>
								{/each}
							</div>
						{:else}
							<div class="flex items-center justify-center h-64">
								<div class="text-center">
									<p class="text-sm font-semibold mb-1" style="color: #0a246a;">Ingen medarbejdere</p>
									<p class="text-xs" style="color: #666;">Der er ingen medarbejdere registreret i øjeblikket</p>
								</div>
							</div>
						{/if}
					
					{/if}
				</div>
			</div>

			<!-- Status bar (XP Style) -->
			<div class="px-2 py-0 text-xs text-gray-700 flex items-center flex-shrink-0" style="background: #ece9d8; border-top: 1px solid #dfdfdf; height: 22px;">

			</div>
		</div>
	</div>
	</div>
</div>