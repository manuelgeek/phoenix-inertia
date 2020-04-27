<template>
	<div>
		<br />
		<flash-message />
		<div class="max-w-sm rounded overflow-hidden shadow-lg bg-white">
			<logo :avatar="user.avatar" />
			<div class="px-6 py-4">
				<div class="font-bold text-xl mb-2">{{ user.name }}</div>
				<p class="text-gray-700 text-base">{{ user.email }}</p>
			</div>
			<div class="px-6 py-4">
				<span
					class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2"
				>
					<button class="modal-open">{{ button_2 }}</button>
				</span>

				<span
					class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2"
				>
					<a href="#" @click.prevent="logout">{{ button }}</a>
				</span>
			</div>
		</div>
		<p class="text-center text-gray-500 text-xs">
			<br />
			<br />&copy;2020 All rights reserved.
		</p>
		<upload-modal />
	</div>
</template>

<script>
	import Logo from "../components/Logo";
	import UploadModal from "../components/UploadModal";
	import FlashMessage from "../components/FlashMessage";

	export default {
		name: "Home",
		components: { FlashMessage, UploadModal, Logo },
		data() {
			return {
				button: "Logout",
				button_2: "Change Avatar"
			};
		},
		methods: {
			logout() {
				this.button = "Loging Out ...";
				this.$inertia.delete("/sessions/" + this.plug_session.phauxth_session_id, this.form);
			}
		},
		computed: {
			user() {
				return this.$page.auth.user;
            },
            plug_session() {
                return this.$page.plug_session
            }
        },
	};
</script>

<style scoped>
</style>
