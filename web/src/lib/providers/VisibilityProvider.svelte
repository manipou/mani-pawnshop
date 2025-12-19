<script lang="ts">
	import { onMount } from "svelte";
	import { visibilityStore as visibility, ShopIndex, PawnData, Config } from "$lib/stores/VisibilityStore";
	import { useNuiEvent } from "$lib/hooks/useNuiEvent";
	import { fetchNui } from "$lib/utils/fetchNui";

	onMount(() => {
		const keyHandler = (e: KeyboardEvent) => {
			if ($visibility && e.code === "Escape") {
				fetchNui("hideUI");
				visibility.hide();
			}
		};

		window.addEventListener("keydown", keyHandler);
		return () => window.removeEventListener("keydown", keyHandler);
	});

	useNuiEvent<{ Shop: number, PawnData: any }>("OpenMenu", (Data: { Shop: number, PawnData: any }) => {
		visibility.show();
		ShopIndex.set(Data.Shop);
		PawnData.set(Data.PawnData);

	});

	useNuiEvent<{ Config: any }>("InitializeUI", (Data: { Config: any }) => {
		Config.set(Data.Config);
	});
</script>

{#if $visibility}
	<slot />
{/if}
