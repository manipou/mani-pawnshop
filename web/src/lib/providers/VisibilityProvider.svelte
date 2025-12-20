<script lang="ts">
	import { onMount } from "svelte";
	import { visibilityStore as visibility, ShopIndex, PawnData, Muted, Config } from "$lib/stores/VisibilityStore";
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

	useNuiEvent<{ Config: any, Muted: boolean }>("InitializeUI", (Data: { Config: any, Muted: boolean }) => {
		Config.set(Data.Config);
		Muted.set(Data.Muted);
	});
</script>

{#if $visibility}
	<slot />
{/if}
